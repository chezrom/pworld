local default = require 'lib.gui.default'
local Class=require 'lib.hc.class'

local lg = love.graphics

local Label=Class{name="Label"}

function Label:construct(label)
	self.label=label
	self.w = default.font:getWidth(label)+5
	self.h = default.font:getHeight()+4
end

function Label:draw(x,y)
	lg.setFont(default.font)
	lg.setColor(default.fgColor)
	lg.print(self.label,x+self.x,y+self.y+2)
end

return Label