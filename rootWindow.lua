local HC=require 'lib.hc'
local gen2d = require 'poisson'
local newPlanet = require 'planet'


local mainComp={x=0,y=0}

local lg = love.graphics
local lm = love.math

local bgStars
local planets={}

local shader
local shaderModel={diffusion=0.8,shininess=9,specular=0.2,active=true}
local collider
local drag

local angLum=0

function shaderModel:send()
	shader:send('diffusion',self.diffusion)
	shader:send('specular',self.specular)
	shader:send('shininess',self.shininess)
end

function shaderModel:setShininess(v)
	self.shininess=v
	shader:send('shininess',self.shininess)
end

function shaderModel:setDiffusion(v)
	self.diffusion=v
	shader:send('diffusion',self.diffusion)
end

function shaderModel:setSpecular(v)
	self.specular=v
	shader:send('specular',self.specular)
end

local lightModel={move=true,heading=-math.pi/4, height=math.pi/2, day=10}

local r1=math.sqrt(2)/2

function lightModel:setDir(lx,ly,lz)

	-- normalize light dir
	local ll = math.sqrt(lx*lx+ly*ly+lz*lz)
	lx,ly,lz = lx/ll,ly/ll,lz/ll
	self.lx,self.ly,self.lz=lx,ly,lz
	
	-- compute halfway vector (for Phong-Blinn reflection  model)
	local hz = 1 + lz
	local hl = math.sqrt(lx*lx+ly*ly+hz*hz)
	self.hx,self.hy,self.hz=lx/hl,ly/hl,hz/hl

end

function lightModel:getHeight()
	return self.height/math.pi/2
end

function lightModel:getHeading()
	return self.heading/math.pi/2
end

function lightModel:send()
	shader:send('lum',{self.lx,self.ly,self.lz})
	shader:send('hw',{self.hx,self.hy,self.hz})
end

function lightModel:updateDir()
	local h=self.heading
	local hx,hy=math.sin(h),-math.cos(h)
	local ht=self.height
	local c=math.sin(ht)
	self:setDir(c*hx,c*hy,math.cos(ht))
	self:send()
end

function lightModel:setHeading(v)
	self.heading = 2 * v * math.pi
	self:updateDir()
end

function lightModel:setHeight(v)
	self.height = 2 * v * math.pi
	self:updateDir()
end

function lightModel:update(dt)
	local pi=math.pi
	if self.move then
		local height = self.height - pi * 2 * dt / self.day
		if height < 0 then height = height + math.pi*2 end
		if self.heightCB then self.heightCB(height) end
		self.height = height
		self:updateDir()
	end
end

local simuModel={move=true,showvel=false}

local function computeStars()
	local floor = math.floor
	local dim=32
	local id = love.image.newImageData(SW,SH)
	local dist=5
	local continue=true
	while continue do
		local points = gen2d(SW,SH,dist)
		if #points > 5 then
			for _,p in ipairs(points) do
				id:setPixel(floor(p.x),floor(p.y),dim/255,dim/255,dim/255)
			end
		else 
			continue=false
		end
		dist=dist * 2
		dim=dim*2
		if (dim > 255) then dim = 255 end
	end
	--bgStars:clear()
	lg.setCanvas(bgStars)
        lg.clear(0,0,0)
	lg.draw(lg.newImage(id),0,0)
	lg.setCanvas()
end


function update_load(rw,dt)
	if loadState == "start" then
		loadState="stars"
	elseif loadState == "stars" then
		computeStars()
		loadState="planet"
		iPlanet=1
	elseif loadState == "planet" then
		planets[iPlanet]:generate()
		iPlanet=iPlanet+1
		if iPlanet > #planets then
			loadState="end"
		end
	else
		rw.update = update_dyn
	end
end

function update_dyn(rw,dt)
	lightModel:update(dt)
	local movePlanets=simuModel.move
	for _,p in ipairs(planets) do
		p:update(dt,movePlanets)
	end
	collider:update(dt)
end


local function treatCollision2(dt,shape1,shape2,dx,dy)
	local p1,p2 = shape1.planet,shape2.planet
	p1:move(dx/2,dy/2)
	p2:move(-dx/2,-dy/2)
end

local function treatCollision(dt,shape1,shape2,dx,dy)
	local p1,p2 = shape1.planet,shape2.planet
	p1:move(dx/2,dy/2)
	p2:move(-dx/2,-dy/2)
	
	local nl = math.sqrt(dx*dx+dy*dy)
	local v1x,v1y=p1:getVelocity()
	local v2x,v2y=p2:getVelocity()
	local v1 = math.sqrt(v1x*v1x+v1y*v1y)
	local v1x,v1y=-v1x/v1,-v1y/v1
	local v2 = math.sqrt(v2x*v2x+v2y*v2y)
	local v2x,v2y=-v2x/v2,-v2y/v2
	local nx,ny=dx/nl,dy/nl
	
	local ps1 = 2*(v1x*nx+v1y*ny)
	local ps2 = -2*(v2x*nx+v2y*ny)
	
	p1:setVelocity((ps1*nx-v1x)*v1,(ps1*ny-v1y)*v1)
	p2:setVelocity((-ps2*nx-v2x)*v2,(-ps2*ny-v2y)*v2)
	
end

local function init()
	SW,SH = lg.getWidth(), lg.getHeight()
	collider = HC(100,treatCollision)
	
	shader = lg.newShader([[
	
		extern vec3 lum;
		extern vec3 hw;
		extern float radius;
		extern float width;
		extern float xoff;
	
		extern float diffusion;
		extern float specular;
		extern float shininess;
		
		vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
		{
			vec2 delta = (tc-vec2(xoff,0)) / vec2(width,1)- vec2(radius,radius);
			float z=length(delta);
			if (z>radius) {
				return vec4(0,0,0,0);
			} else {
				z=z/radius;
				vec4 tcol=Texel(tex,tc);
				vec3 r=vec3(delta.x/radius,delta.y/radius,sqrt(1-z*z));
				float l1 = dot(r,lum);
				if (l1>0) {
					float l2=max(dot(r,hw),0);
					l1 = diffusion * l1 + specular * pow(l2,shininess);
				} else {
					l1=0;
				}
				return vec4(tcol.xyz*l1,1);
			}
		}
		
	]])
	shaderModel:send()
	lightModel:updateDir()	
	bgStars = lg.newCanvas(SW,SH)

	local pts = gen2d(SW-100,SH-100,250)
	for _,p in ipairs(pts) do
		table.insert(planets,newPlanet(collider,50+math.floor(p.x),50+math.floor(p.y)))
	end
end



function mainComp:draw()
	lg.setColor(1,1,1)
	lg.draw(bgStars)
	local ls = nil
	if shaderModel.active then
		lg.setShader(shader)
		ls=shader
	end
	for _,p in ipairs(planets) do
		p:draw(ls)
	end
	lg.setShader()
	if simuModel.showvel then
		for _,p in ipairs(planets) do
			local x,y,vx,vy = p.x,p.y,p.vx,p.vy
			lg.line(x,y,x+vx,y+vy)
		end
	end
end



local Class=require 'lib.hc.class'
local Container = require 'lib.gui.container'
local MouseManager = require 'lib.gui.mouseManager'
local Window = require 'lib.gui.window'
local ShaderConfigWindow = require 'shaderConfigWindow'
local LightConfigWindow = require 'lightConfigWindow'
local SimuConfigWindow = require 'simuConfigWindow'
local Popup = require 'lib.gui.popup'
local RootWindow=Class {inherits={Container},name="RootWindow"}
local PlanetDragger=Class {inherits={MouseManager}}

local function dummy() print("dummy func called") end

function RootWindow:construct()
	init()
	Container.construct(self,SW,SH,mainComp)

	loadState="start"
	self.update = update_load

	--
	self.shaderConfig = ShaderConfigWindow(shaderModel)
	self.lightConfig  = LightConfigWindow(lightModel)
	self.simuConfig  = SimuConfigWindow(simuModel)
	self.shaderConfig.closeCB = function () self:remove(self.shaderConfig) end
	self.lightConfig.closeCB = function () self:remove(self.lightConfig) end
	self.simuConfig.closeCB = function () self:remove(self.simuConfig) end
	
	self.rootMenu = Popup {
		"Actions",
		{"Regenerate",function ()  self.update=update_load; loadState='start'; end},
		--{"Reposition",function(x,y) self:repositionPlanets(x,y) end},
		{"Add Planet",function(x,y) self:addPlanet(x,y) end},
		{"Remove Planet",function(x,y) self:removePlanet(x,y) end},
		"Settings",
		{"General",function(x,y) self:display(self.simuConfig,x,y) end},
		{"Shader",function(x,y) self:display(self.shaderConfig,x,y) end},
		{"Light",function(x,y) self:display(self.lightConfig,x,y) end}
		}
	--self:popup(popup,10,200)
end

function RootWindow:repositionPlanets(x,y)
	table.insert(planets,newPlanet(collider,x,y))
	self.update=update_load
	iPlanet = #planets
	loadState='planet'
end

function RootWindow:addPlanet(x,y)
	table.insert(planets,newPlanet(collider,x,y))
	self.update=update_load
	iPlanet = #planets
	loadState='planet'
end

function RootWindow:removePlanet(x,y)
	if #planets > 1 then
		local p = table.remove(planets,#planets)
		if p.shape then collider:remove(p.shape) end
	end
end

function PlanetDragger:construct(shape,x,y)
	local p=shape.planet
	self.shape=shape
	self.vx,self.vy=p:getVelocity()
	p:setVelocity(0,0)
	self.ox,self.oy=x,y
	collider:setGhost(shape)
	local ip
	for i,pp in ipairs(planets) do
		if pp==p then
			ip=i
			break
		end
	end
	if ip then
		table.remove(planets,ip)
		table.insert(planets,p)
	end
end

function PlanetDragger:unclick(left,x,y)
    if left then
		local s=self.shape
		local p=s.planet
		p:setVelocity(self.vx,self.vy)
		collider:setSolid(s)
		return true
	end
end

function PlanetDragger:move(x,y)
	self.shape.planet:move(x-self.ox,y-self.oy)
	self.ox,self.oy=x,y
end

function mainComp:click(left,x,y)
	if left then
		local shapes= collider:shapesAt(x,y)
		if shapes and #shapes > 0 then
			local s = shapes[1]
			return PlanetDragger(s,x,y)
		end
	else
		self.parent:popup(self.parent.rootMenu,x,y)
	end
end

return RootWindow
