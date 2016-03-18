local Class=require 'lib.hc.class'
local MouseManager=require 'lib.gui.mouseManager'

local ZoneClicker=Class {inherits={MouseManager}}

function ZoneClicker:construct(comp,x,y,w,h,target)
	self.x,self.y=x,y
	self.w,self.h=w,h
	self.comp = comp
	self.target=target
end

function ZoneClicker:move(x,y)
	if x>=0 and y>=0 and x<=self.w and y<=self.h then
		self.comp.active=self.target
	else
		self.comp.active=not self.target
	end
end

function ZoneClicker:unclick(left,x,y)
    if left then
		if self.ackCB then
			self.ackCB(self.comp.active)
		end
		return true
	end
end

return ZoneClicker