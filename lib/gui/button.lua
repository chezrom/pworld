local default = require 'lib.gui.default'
local ZoneClicker = require 'lib.gui.zoneClicker'
local Class=require 'lib.hc.class'

local lg = love.graphics

local Button=Class{name="Button"}

function Button:construct(label,border)
	self.label=label
	local lw = default.font:getWidth(label)
	local lh = default.font:getHeight()
	local w,h,olx,oly
	if border then
		w,h = lw+6,lh+6
		olx,oly=3,3
	else	
		w,h = lw+4,lh+4
		olx,oly=2,2
	end
	self.border=border
	self.h=h
	self.w=w
	self.lx,self.ly=olx,oly
end

function Button:draw(px,py)
	local cx,cy=px+self.x,py+self.y
	lg.setColor(default.fgColor)
	lg.setFont(default.font)
	if self.active then
		lg.rectangle('fill',cx,cy,self.w,self.h)
		lg.setColor(default.bgColor)
	elseif self.border then
		lg.rectangle('line',cx,cy,self.w,self.h)
	end
	lg.print(self.label,self.lx+cx,cy+self.ly)
end

function Button:click(left,x,y)
	local lx,ly = x-self.x,y-self.y
	if left then
		local zc = ZoneClicker(self,self.x,self.y,self.w,self.h,true)
		zc.ackCB = 	function (v) 
						if v then 
							self.active=false
							if self.pushCB then
								self.pushCB()
							end
						end 
					end
		return zc
	end
end

function Button:expend(w,h)
	local fw,fh = math.max(self.w,w), math.max(self.h,h)
	if fw > self.w then
		self.lx = self.lx + math.floor((fw - self.w)/2)
		self.w=fw
	end
	if fh > self.h then
		self.ly = self.ly + math.floor((fh-self.h)/2)
		self.h=fh
	end
end

return Button