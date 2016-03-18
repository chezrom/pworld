local Class=require 'lib.hc.class'
local Container=Class {}

local function inComp(comp,x,y)
	local cx,cy = x-comp.x,y-comp.y
	return cx>=0 and cy>=0 and cx<comp.w and cy<comp.h
end

function Container:construct(w,h,bgComp)
	self.x,self.y,self.w,self.h=0,0,w,h
	bgComp.x,bgComp.y,bgComp.w,bgComp.h=0,0,w,h
	bgComp.parent=self
	self.children={}
	self.background=bgComp
	self.hot=nil -- component with the mouse pointer on
end

function Container:getPosition() 
	return self.x,self.y 
end

function Container:moveTo(x,y) 
	self.x,self.y =x,y
end

function Container:move(dx,dy) 
	self.x,self.y =self.x+dx,self.y+dy
end

function Container:draw(px,py)
	local xx,yy=px+self.x,py+self.y
	self.background:draw(xx,yy)
	for _,c in ipairs(self.children) do
		c:draw(xx,yy)
	end
end

function Container:mouseIn(px,py)
	local xx,yy=px-self.x,py.self.y
	local ch = self.hot
	if ch and inComp(self.hot,xx,yy) then
		return -- mouse pointer always in hot component
	end
	if ch and ch.mouseOut then
		ch:mouseOut()
	end	
	ch=self:hit(xx,yy)
	if ch.mouseIn then
		ch:mouseIn(xx,yy)
	end
	self.hot=ch
end

function Container:mouseOut()
	if self.hot and self.hot.mouseOut then
		self.hot:mouseOut()
	end
	self.hot=nil
end


function Container:click(left,px,py)
	
	local mgr=nil
	local xx,yy=px-self.x,py-self.y
	local c=self:hit(xx,yy)
	if self.popup and c ~= self.popup then
		self:remove(self.popup)
	end
	if c.click then
		mgr = c:click(left,xx,yy)
	elseif self.background.click then
		mgr = self.background:click(left,xx,yy)
	end
	if mgr then
		mgr:add(self.x,self.y)
	end
	return mgr
end

function Container:hit(lx,ly)
    local comp=self.background
	if #self.children>0 then 
		for i=#self.children,1,-1 do
			local c=self.children[i]
			--print("test hit",c,"with ("..lx..","..ly..") c at ("..c.x..","..c.y..") "..c.w.."x"..c.h)
			if inComp(c,lx,ly) then
				--print("***HIT***",c)
				comp=c
				break
			end
		end
	end
	return comp
end

function Container:setDimension(w,h)
	self.w,self.h=w,h
	local bgComp = self.background
	if bgComp.setDimension then
		bgComp:setDimension(w,h)
	else
		bgComp.w,bgComp.h=w,h
	end
end

function Container:add(comp)
	table.insert(self.children,comp)
	comp.parent=self
end

function Container:remove(comp)
	local ic=0
	for i,c in ipairs(self.children) do
		if c==comp then
			ic=i
			break
		end
	end
	if ic > 0 then
		table.remove(self.children,ic)
	end
	if self.popup==comp then
		self.popup=nil
	end
end

function Container:hasChild(comp)
	local ic=0
	for i,c in ipairs(self.children) do
		if c==comp then
			ic=i
			break
		end
	end
	if ic > 0 then
		return true
	else 
		return false
	end
end

function Container:display(comp,x,y)
	local w,h = comp.w,comp.h
	local tw,th=self.w,self.h
	if x + w > tw then x = tw-w end
	if y + h > th then y = th-h end
	comp.x,comp.y=x,y
	if not self:hasChild(comp) then
		self:add(comp)
	end
end

function Container:top(comp)
	self:remove(comp)
	self:add(comp)
end

function Container:popup(comp,x,y)
	if self.popup then
		self:remove(self.popup)
	end
	self:display(comp,x,y)
	self.popup=comp
end

return Container