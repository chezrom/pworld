local lg=love.graphics
local lm=love.mouse

local RootWindow = require 'rootWindow'
local root

local mouseManager=nil

function love.update(dt)
	if mouseManager then mouseManager:update(lm.getPosition()) end
	root:update(dt)
end

function love.draw()
	root:draw(0,0)	
end

function love.load()
	math.randomseed(os.time())
	root=RootWindow()
end

function love.mousepressed( x, y, button )
	if not mouseManager then
		mouseManager = root:click(button==1,x,y)
	end
end

function love.mousereleased( x, y, button ) 
	if mouseManager and mouseManager:unclickMouse(button==1,x,y) then
		mouseManager=nil
	end
end
