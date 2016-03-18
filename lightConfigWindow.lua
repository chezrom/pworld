local Class=require 'lib.hc.class'
local Window = require 'lib.gui.window'
local Label = require 'lib.gui.label'
local Output = require 'lib.gui.output'
local HSlider = require 'lib.gui.hslider'
local CheckBox = require 'lib.gui.checkbox'
local Panel = require 'lib.gui.panel'

local GridPlacer = require 'lib.gui.gridPlacer'
local Roto = require 'custom.roto'

local LightConfigWindow = Class {inherits={Window},name='LightConfigWindow'}

function LightConfigWindow:construct(lightModel)
	Window.construct(self,"Light Source Setting",10,10)
	local panel = Panel()

	local gp=GridPlacer()
	
	gp:add(Label("Heading"),{row=1,col=1,xalign='center'})
	gp:add(Label("Height"),{row=1,col=2,xalign='center'})

	local r1=Roto(150)
	local r2=Roto(150)
	
	r1:setValue(lightModel:getHeading())
	r2:setValue(lightModel:getHeight())
	lightModel.heightCB = function (h) r2:setValue(h/2/math.pi) end
	r1.ackCB=function (v) lightModel:setHeading(v) end
	r2.ackCB=function (v) lightModel:setHeight(v) end
	gp:add(r1,{row=2,col=1,xalign='center',border=5})
	gp:add(r2,{row=2,col=2,xalign='center',border=5})

	local cb=CheckBox("Move light source")
	gp:add(cb,{row=3,col=1,colspan=2,xalign='left'})

	cb:setValue(lightModel.move)
	cb.ackCB = function (v)
		lightModel.move= v
		r2.enabled=not v	
	end
 
	r2.enabled=false
	
	gp:inject(panel,1)

	self:setMainComponent(panel)
end

return LightConfigWindow