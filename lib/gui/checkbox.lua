local default = require 'lib.gui.default'
local ZoneClicker = require 'lib.gui.zoneClicker'
local Class=require 'lib.hc.class'

local lg = love.graphics

local CheckBox=Class{name="CheckBox"}
local cbSize=10

function CheckBox:construct(label)
	self.label=label
	local lw = default.font:getWidth(label)
	local lh = default.font:getHeight()
	local h =math.max(lh,cbSize+6)
	self.lx=cbSize+6+5
	self.w=self.lx+lw
	self.ly=math.floor((h-lh)/2)
	self.cby=math.floor((h-cbSize-6)/2)
	self.h=h
end

function CheckBox:draw(px,py)
	local cx,cy=px+self.x,py+self.y
	lg.setColor(default.fgColor)
	lg.setFont(default.font)
	lg.rectangle('line',cx,cy+self.cby,cbSize+6,cbSize+6)
	lg.print(self.label,self.lx+cx,cy+self.ly)
	if self.active then
		lg.rectangle('fill',cx+3,cy+self.cby+3,cbSize,cbSize)
	end
end

function CheckBox:setValue(v)
	self.active=v
	if self.ackCB then self.ackCB(v) end	
end

function CheckBox:click(left,x,y)
	local lx,ly = x-self.x,y-self.y
	if left and lx>=0 and ly>=self.cby and lx <cbSize+6 and ly<=cbSize+6+self.cby then
		--self.active= not self.active
		local zc = ZoneClicker(self,self.x+0,self.y+self.cby,cbSize+6,cbSize+6,not self.active)
		--local zc = ZoneClicker(self,0,self.cby,cbSize+6,cbSize+6,not self.active)
		zc.ackCB=self.ackCB
		return zc
	end
end

return CheckBox