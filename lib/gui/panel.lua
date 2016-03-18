local Class=require 'lib.hc.class'
local Container = require 'lib.gui.container'

local lg = love.graphics

local Panel=Class{inherits={Container},name="Panel"}

local function pcompDraw(c,x,y) end

function Panel:construct()
	local comp={draw=pcompDraw}
	Container.construct(self,w,h,comp)
end

return Panel