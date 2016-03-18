local Class=require 'lib.hc.class'
local Window = require 'lib.gui.window'
local Label = require 'lib.gui.label'
local Output = require 'lib.gui.output'
local HSlider = require 'lib.gui.hslider'
local CheckBox = require 'lib.gui.checkbox'
local Panel = require 'lib.gui.panel'

local GridPlacer = require 'lib.gui.gridPlacer'

local ShaderConfigWindow = Class {inherits={Window},name='ShaderConfigWindow'}

function ShaderConfigWindow:construct(shaderModel)
	Window.construct(self,"Shader Setting",10,10)
	local panel = Panel()

	local gp=GridPlacer()
	
	local cb=CheckBox("Use shader")
	
	gp:add(cb,{row=0,col=1,colspan=3,xalign='left'})

	cb:setValue(shaderModel.active)
	cb.ackCB = function (v) shaderModel.active = v end
	
	local l1,l2,l3 = Label("Diffusion"),Label("Specular"),Label("Shininess")
	
	gp:add(l1,{row=1,col=1,xalign='left'})
	gp:add(l2,{row=2,col=1,xalign='left'})
	gp:add(l3,{row=3,col=1,xalign='left'})

	local s1,s2,s3 = HSlider(150,0,2),HSlider(150,0,2),HSlider(150,1,100)
	
	gp:add(s1,{row=1,col=2,xalign='left'})
	gp:add(s2,{row=2,col=2,xalign='left'})
	gp:add(s3,{row=3,col=2,xalign='left'})
	
	local o1,o2,o3 = Output(50,'right','%3.2f'),Output(50,'right','%3.2f'),Output(50,'right','%d')

	gp:add(o1,{row=1,col=3,xalign='left'})
	gp:add(o2,{row=2,col=3,xalign='left'})
	gp:add(o3,{row=3,col=3,xalign='left'})
	
	s1.ackCB = function (v) 
		o1:setValue(v)
		shaderModel:setDiffusion(v)
	end
	s2.ackCB = function (v) 
		o2:setValue(v) 
		shaderModel:setSpecular(v)
	end
	s3.ackCB = function (v) 
		o3:setValue(v) 
		shaderModel:setShininess(v)
	end

	s1.curCB = function (v) o1:setValue(v) end
	s2.curCB = function (v) o2:setValue(v) end
	s3.curCB = function (v) o3:setValue(v) end
	
	s1:setValue(shaderModel.diffusion)
	s2:setValue(shaderModel.specular)
	s3:setValue(shaderModel.shininess)
	
	gp:inject(panel,1)

	self:setMainComponent(panel)
end

return ShaderConfigWindow