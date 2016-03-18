local default = require 'lib.gui.default'
local Class=require 'lib.hc.class'
local Container = require 'lib.gui.container'
local MouseManager = require 'lib.gui.mouseManager'
local ZoneClicker = require 'lib.gui.zoneClicker'

local Label = require 'lib.gui.label'
local Button = require 'lib.gui.button'
local GridPlacer = require 'lib.gui.gridPlacer'

local lg = love.graphics

local function pcompDraw(c,x,y)
	local w,h=c.w,c.h
	lg.setColor(default.bgColor)
	lg.rectangle('fill',x,y,w,h)
	lg.setColor(default.fgColor)
	lg.rectangle('line',x,y,w,h)
end

local Popup=Class{inherits={Container},name="Popup"}

function Popup:construct(menudesc)
	local comp={draw=pcompDraw}
	Container.construct(self,w,h,comp)
	local gp=GridPlacer()
	for i,d in ipairs(menudesc) do
		local c,bw
		if type(d) == "table" then
			local l,f = d[1],d[2]
			if type(l) == "string" and type(f) == "function" then
				c=Button(d[1],true)
				c.pushCB = 	function()
								self.parent:remove(self)
								f(self.x,self.y)
							end
			else
				c=nil
			end
			bw=3
		else
			c=Label(tostring(d))
			bw=2
		end
		if c then
			gp:add(c,{row=i,col=1,border=bw,expend=true})
		end
	end
	gp:inject(self,2)
end

return Popup
