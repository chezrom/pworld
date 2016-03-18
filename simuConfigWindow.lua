local Class=require 'lib.hc.class'
local Window = require 'lib.gui.window'
local Label = require 'lib.gui.label'
local Output = require 'lib.gui.output'
local HSlider = require 'lib.gui.hslider'
local CheckBox = require 'lib.gui.checkbox'
local Panel = require 'lib.gui.panel'

local GridPlacer = require 'lib.gui.gridPlacer'

local SimuConfigWindow = Class {inherits={Window},name='SimuConfigWindow'}

function SimuConfigWindow:construct(simuModel)
	Window.construct(self,"General Setting",10,10)
	local panel = Panel()
	local gp=GridPlacer()
		
	local cb1=CheckBox("Move planets")
	cb1:setValue(simuModel.move)
	cb1.ackCB = function (v) simuModel.move = v end

	local cb2=CheckBox("Show velocity")
	cb2:setValue(simuModel.showvel)
	cb2.ackCB = function (v) simuModel.showvel = v end
	
	gp:add(cb1,{row=1,col=1,xalign='left'})
	gp:add(cb2,{row=2,col=1,xalign='left'})
	
	gp:inject(panel,1)
	self:setMainComponent(panel)
end

return SimuConfigWindow