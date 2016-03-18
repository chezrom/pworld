local default = require 'lib.gui.default'
local Class=require 'lib.hc.class'

local lg = love.graphics

local Output=Class{name="Output"}

function Output:construct(w,align,format)
	self.text="?"
	self.w = w
	self.h = default.font:getHeight()+4
	self.format=format
	self.align=align or 'left'
end

function Output:setValue(v)
	self.text = string.format(self.format,v)
end
function Output:draw(x,y)
	lg.setFont(default.font)
	lg.setColor(default.fgColor)
	lg.printf(self.text,x+self.x,y+self.y+2,self.w,self.align)
end

return Output