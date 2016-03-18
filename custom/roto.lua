local default = require 'lib.gui.default'
local Class=require 'lib.hc.class'
local MouseManager = require 'lib.gui.mouseManager'

local lg = love.graphics

local Roto=Class{name="Roto"}
local RotoDragger=Class {inherits={MouseManager}}

local dmin=5
local dmin2=dmin*dmin

function Roto:construct(sz)
	self.h=sz
	self.w=sz
	self.r=math.floor(sz/2)
	self.r2=self.r*self.r
	self.rm12=(self.r-1)*(self.r-1)
	self.enabled=true
	self.value=0
	self.ux=0
	self.uy=-self.r
end

function Roto:draw(ax,ay)
	lg.setColor(default.fgColor)
	local x,y = ax+self.x,ay+self.y
	local xc,yc=x+self.r,y+self.r
	lg.circle('line',xc,yc,self.r)
	local ow 
	if self.active then
		ow= lg.getLineWidth()
		lg.setLineWidth(3)
	end
	lg.line(xc,yc,xc+self.ux,yc+self.uy)
	if self.active then
		lg.setLineWidth(ow or 1)
	end
end

function Roto:click(left,x,y)
	local lx,ly = x-self.x-self.r,y-self.y-self.r
	local ux2=lx*lx+ly*ly
	if left and self.enabled and ux2 <= self.r2 and ux2> dmin2 then
		self.active=true
		local ux=math.sqrt(ux2)
		return RotoDragger(self,lx/ux,ly/ux)
	end
end

function Roto:setValue(v)
	if v>1 then v=1 end
	while v<0 do v=v+1 end
	self.value=v
	local alpha = 2*math.pi*v
	self.uy = -self.r * math.cos(alpha)
	self.ux= self.r * math.sin(alpha)
	if self.ackCB and self.enabled then self.ackCB(v) end
end

function RotoDragger:construct(roto,rx,ry)
	self.roto=roto
	self.x=roto.x+roto.r
	self.y=roto.y+roto.r
	self.rx,self.ry=rx,ry
end

function RotoDragger:move(x,y)
	local ux2=x*x+y*y
	if ux2 > dmin2 then
		local roto=self.roto
		local ux=math.sqrt(ux2)
		local x,y=x/ux,y/ux
		local rx,ry=self.rx,self.ry
		
		local xx=x*rx+y*ry
		local yy=y*rx-ry*x
		local ux,uy=roto.ux,roto.uy
		
		ux=ux*xx-uy*yy
		uy=uy*xx+ux*yy
		
		local d2=ux*ux+uy*uy
		if d2 < roto.rm12 then
			d2=roto.r/math.sqrt(d2)
			ux=ux*d2
			uy=uy*d2
		end
		self.rx,self.ry=x,y
		roto.ux,roto.uy=ux,uy
	end
end

function RotoDragger:unclick(left,x,y)
	local roto=self.roto
	roto.active=false
	local ux,uy=roto.ux,roto.uy
    local alpha=math.atan2(ux,-uy)/2/math.pi
	while alpha<0 do alpha=alpha+1 end
	roto:setValue(alpha)
	--print("set v ="..alpha)
	return true
end

return Roto