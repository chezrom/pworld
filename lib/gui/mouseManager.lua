local Class=require 'lib.hc.class'
local MouseManager=Class {}

function MouseManager:construct(x,y)
	self.x,self.y=0,0
end

function MouseManager:add(x,y)
	local mx,my = self.x or 0, self.y or 0
	mx,my = x + mx, y + my
	self.x,self.y=mx,my
end
function MouseManager:update(x,y)
	self:move(x-self.x,y-self.y)
end

function MouseManager:clickMouse(left,x,y)
	if self.click then
		return self:click(left,x-self.x,y-self.y)
	end
end

function MouseManager:unclickMouse(left,x,y)
	if self.unclick then
		return self:unclick(left,x-self.x,y-self.y)
	end
end

return MouseManager