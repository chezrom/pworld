local default = require 'lib.gui.default'
local Class=require 'lib.hc.class'
local Container = require 'lib.gui.container'
local MouseManager = require 'lib.gui.mouseManager'
local ZoneClicker = require 'lib.gui.zoneClicker'

local lg = love.graphics

local Window=Class{inherits={Container},name="Window"}
local WindowComp=Class {name='WindowComp'}
local WindowDragger=Class {inherits={MouseManager}}

function Window:construct(title,w,h)
	local wcomp = WindowComp(title)
	local mw,mh = wcomp:getMinDimension()
	if mw > w then w = mw end
	if mh > h then h = mh end
	Container.construct(self,w,h,wcomp)
end

function WindowDragger:construct(window,ox,oy)
	self.w = window
	self.ox,self.oy=ox,oy
end

function WindowDragger:move(x,y)
	local dx,dy = x-self.ox,y-self.oy
	self.w:move(dx,dy)
	self:add(dx,dy)
end

function WindowDragger:unclick(left,x,y)
    if left then
		return true
	end
end

function WindowComp:construct(title)
	self.title = title
	self.tw = default.titleFont:getWidth(title)
	self.th = default.titleFont:getHeight() + 4
	self.bw = default.titleFont:getWidth("X")+4
end

function WindowComp:getMinDimension()
	return self.tw+self.bw+15,self.th+5
end

function WindowComp:draw(sx,sy)
	lg.setColor(default.bgColor)
	lg.rectangle('fill',sx,sy,self.w,self.h)
	lg.setColor(default.fgColor)
	lg.rectangle('line',sx,sy,self.w,self.h)
	lg.line(sx,sy+self.th,sx+self.w-1,sy+self.th)
	lg.line(sx+self.w-self.bw,sy,sx+self.w-self.bw,sy+self.th)
	lg.setFont(default.titleFont)
	lg.printf(self.title,sx,sy+2,self.w-self.bw,'center')
	if self.active then
		lg.rectangle('fill',sx+self.w-self.bw,sy,self.bw,self.th)
		lg.setColor(default.bgColor)
	end
	lg.printf("X",sx+self.w-self.bw,sy+2,self.bw,'center')
end

function WindowComp:click(left,x,y)
	self.parent.parent:top(self.parent)
	if left then
		if y < self.th and x >= self.w - self.bw then
			local zc = ZoneClicker(self,self.w-self.bw,0,self.bw,self.th,true)
			zc.ackCB = function (v) 
				self.active=false;
				if v then
					local cb = self.closeCB or self.parent.closeCB
					if cb then cb() end
				end
				end
			return zc
		else
			return WindowDragger(self.parent,x,y)
		end
	end
end

function Window:setMainComponent(comp)
	self.children={comp}
	comp.parent=self
	local mw,mh = self.background:getMinDimension()
	if mw < comp.w+10 then mw = comp.w +10 end
	local fh = mh + comp.h+10
	comp.x = math.floor((mw - comp.w)/2)
	comp.y = mh + 2
	self:setDimension(mw,fh)
end

return Window