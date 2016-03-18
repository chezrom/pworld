local lg = love.graphics
local lm = love.math

local pmethods={}

local function earth(u,v) 
	local cr,cb,cg
	if u < 0.5 then
		cb = 0.3+u/2
		cr=0
		cg=0
	else
		cb = 0
		cg = u
		cr = 2*(u -0.5)
	end
	--v=v*v*(3-2*v)
	v=v * v * v * ( v * (6*v-15) + 10)
	cb = (1-v)*cb + v * 0.8
	cr = (1-v)*cr + v * 0.8
	cg = (1-v)*cg + v * 0.8
	return cr,cg,cb
end

local function ocean(u,v)
	return earth(u * u ,v)
end

local function bizare1(u)
	return u*u,u * (1-u)*4,(1-u)*(1-u)
end

local function bizare2(u)
	return bizare1(u*u)
end
				

local colFuncs={earth,ocean}

local function getPlanetImages(radius,nbFrames)

	local colFunc = colFuncs[math.random(1,#colFuncs)]
	
	local ox= 50*math.random() - 25
	local oy= 50*math.random() - 25
	local oz= 50*math.random() - 25

	local nx= 50*math.random() - 25
	local ny= 50*math.random() - 25
	local nz= 50*math.random() - 25
	
	local angDelta = math.pi*2/nbFrames
	
	local angRot = math.pi * 2 * math.random()
	
	local sz =8
	while 2*radius > sz do sz = sz *2 end

	-- determination of the rotation axe
	local ux = 2*math.random() - 1
	local uy = 2*math.random() - 1
	local uz = 2*math.random() - 1
	local ul = math.sqrt(ux*ux+uy*uy+uz*uz)
	ux=ux/ul
	uy=uy/ul
	uz=uz/ul
	
	-- transformation matrix
	local m11,m12,m13,m21,m22,m23,m31,m32,m33
	
	-- temporary matrix, used for matrix 
	local n11,n12,n13,n21,n22,n23,n31,n32,n33

	-- determination of the main matrix (a rotation of angRot around (ux,uy,uz))
	do 
		local c = math.cos(angRot)
		local s = math.sin(angRot)
		local cc = 1-c
		local xs,ys,zs = ux*s,uy*s,uz*s
		local xc,yc,zc = ux*cc,uy*cc,uz*cc
		local xyc,yzc,zxc = ux*yc, uy*zc, uz*xc
		m11,m12,m13 = ux*xc+c, xyc -zs, zxc+ys
		m21,m22,m23 = xyc + zs, uy * yc + c, yzc -xs
		m31,m32,m33 = zxc - ys, yzc+xs, uz*zc + c
	end
	
	-- determination of the rotation matrix (around z axe of angDelta)
	local cd = math.cos(angDelta)
	local sd = math.sin(angDelta)
	
	
	local id = love.image.newImageData(sz*nbFrames,sz)
	local xc = (2*radius-1)/2
	local yc = xc
	local r2=radius*radius
	for iframe=0,nbFrames-1 do
		local ww = math.sin(2*math.pi/nbFrames*iframe)/4

	for x=0,2*radius-1 do
		local u2 = (x-xc)*(x-xc)
		local x0=(x-xc)/radius
		for y=0,2*radius-1 do
			local d2=u2+(y-yc)*(y-yc)
			if d2 <=r2 then
				z=math.sqrt(r2-d2)
				local y0 = (y-yc)/radius 
				local z0 = z/radius 

				-- transform coordinates with the transformation matrix
				local xx = nx + m11 * x0 + m12 * y0 + m13 * z0
				local yy = ny + m21 * x0 + m22 * y0 + m23 * z0
				local zz = nz + m31 * x0 + m32 * y0 + m33 * z0

				-- cloud computation
				local vx,vy,vz = 0.3*xx,0.5*yy,1.3*zz
				local v1 = math.abs(2*lm.noise(vx,vy,vz,ww) - 1)
				local v2 = math.abs(2*lm.noise(2*vx,2*vy,2*vz,2*ww)-1)
				local v3 = math.abs(2*lm.noise(4*vx,4*vy,4*vz,4*ww)-1)
				local v = v1 + v2/2 + v3/4 
				v=v/1.75
		
		        -- get coordinate for land
				local xx = xx+ox-nx
				local yy = yy+oy-ny
				local zz = zz+oz-nz

				-- land computation
				local u1 = lm.noise(xx,yy,zz)
				local u2 = lm.noise(2*xx,2*yy,2*zz)
				local u3 = lm.noise(4*xx,4*yy,4*zz)
				local u = u1 + u2/2 + u3/4
				u=u/1.75

				local cr,cg,cb = colFunc(u,v)
				id:setPixel(x+sz*iframe,y,cr *255,cg*255,cb*255,255)
			end
		end
	end
	
	    -- multiply the incremental rotation matrix by the transformation matrix (order matters)
		-- and store the result as the new transformation matrix
	    n11=m11*cd-m21*sd
		n12=m12*cd-m22*sd
		n13=m13*cd-m23*sd
		
	    n21=m11*sd+m21*cd
		n22=m12*sd+m22*cd
		n23=m13*sd+m23*cd

		
		m11,m12,m13 = n11,n12,n13
		m21,m22,m23 = n21,n22,n23
		
	end
	return lg.newImage(id)
end


function pmethods:draw(shader)
	if self.img then
		if shader then
			shader:send('width',1/self.nbFrames)
			shader:send('radius',self.rshader)
			shader:send('xoff',self.iframe/self.nbFrames)
		end
		lg.draw(self.img,self.quad,self.x-self.radius,self.y-self.radius)
	end
end

function pmethods:move(rx,ry)
	self.shape:move(rx,ry)
	self.x,self.y = self.shape:center()
end

function pmethods:moveTo(x,y)
	self.shape:moveTo(rx,ry)
	self.x,self.y = self.shape:center()
end

function pmethods:getVelocity()
	return self.vx,self.vy
end

function pmethods:setVelocity(vx,vy)
	self.vx,self.vy=vx,vy
end

function pmethods:update(dt,movePlanet)
	if self.img then
		if movePlanet then
		local x = self.x + self.vx * dt
		local y = self.y + self.vy * dt
		local r = self.radius
		
		if x-r < 0 then
			self.vx = -self.vx
			x = r
		end
		if y-r < 0 then
			self.vy = -self.vy
			y=r
		end
		if x+r > SW then
			self.vx=-self.vx
			x=SW-r
		end
		if y+r > SH then
			self.vy = -self.vy
			y=SH-r
		end
		self.x=x
		self.y=y
		self.shape:moveTo(x,y)
		end
		
		self.timer=self.timer+dt
		if self.timer > self.trig then
			self.timer = self.timer - self.trig
			self.iframe = self.iframe + 1
			if self.iframe >= self.nbFrames then
				self.iframe = 0
			end
			self:setQuad()
		end
	end
end


function pmethods:setQuad()
	local sz = self.sz
	self.quad = lg.newQuad(self.iframe*sz,0,sz,sz,sz*self.nbFrames,sz)
end

function pmethods:generate()
	self.nbFrames = 64
	local oldRadius = self.radius
	self.radius = math.random(30,50)
	self.shape:scale(self.radius/oldRadius)
	self.img =  getPlanetImages(self.radius,self.nbFrames)
	self.sz = self.img:getHeight()
	self.rshader = self.radius/self.sz
	self.iframe=0
	self:setQuad()
	self.timer=0
	self.trig = self.delay/self.nbFrames
	
	local alpha = 2*math.pi*math.random()
	local speed = math.random(100,150)
	self.vx = speed * math.cos(alpha)
	self.vy = speed * math.sin(alpha)

end


local function newPlanet(collider,x,y)
	local p=setmetatable({x=x,y=y,radius=100,vx=0,vy=0},{__index=pmethods})
	p.shape=collider:addCircle(x,y,p.radius)
	p.shape.planet=p 
	p.delay=3
	return p
end

return newPlanet