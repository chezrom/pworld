local default = require 'lib.gui.default'
local Class=require 'lib.hc.class'
local MouseManager = require 'lib.gui.mouseManager'

local lg = love.graphics

local HSlider=Class{name="HSlider"}
local HSliderDragger=Class {inherits={MouseManager}}

local cursorSize=10

function HSlider:construct(w,minValue,maxValue)
	self.value,self.minValue,self.maxValue=minValue,minValue,maxValue
	self.h=cursorSize+6
	self.w=w
	self.xSlide=3
	self.xMinSlide=3
	self.xMaxSlide=w-3-cursorSize
end

function HSlider:draw(ax,ay)
	lg.setColor(default.fgColor)
	local x,y = ax+self.x,ay+self.y
	lg.rectangle('line',x,y,self.w,self.h)
	lg.rectangle((self.active and 'fill') or 'line',x+self.xSlide,y+3,cursorSize,cursorSize)
end

function HSlider:click(left,x,y)
	local lx = x-self.x
	if left and lx>=self.xSlide and lx <self.xSlide+cursorSize then
		self.active=true
		return HSliderDragger(self,x,y)
	end
end

function HSlider:setValue(v)
	local v=math.max(math.min(self.maxValue,v),self.minValue)
	self.value=v
	self.xSlide=self.xMinSlide + (self.xMaxSlide-self.xMinSlide) * (v-self.minValue)/(self.maxValue-self.minValue)
	if self.ackCB then self.ackCB(v) end
end

function HSliderDragger:construct(comp,x,y)
	self.dx=x-comp.x-comp.xSlide
	self.slider=comp
	self.ratio = (comp.maxValue-comp.minValue) / (comp.xMaxSlide-comp.xMinSlide) 
end

function HSliderDragger:move(x,y)
	local comp=self.slider
	local xSlide=x - comp.x -self.dx
	comp.xSlide = math.min(math.max(comp.xMinSlide,xSlide),comp.xMaxSlide)
	comp.value = comp.minValue + (comp.xSlide - comp.xMinSlide) * self.ratio
	if comp.curCB then
		comp.curCB(comp.value)
	end
end

function HSliderDragger:unclick(left,x,y)
	local comp=self.slider
	comp.active=false
	if comp.ackCB then comp.ackCB(comp.value) end
	return true
end

return HSlider