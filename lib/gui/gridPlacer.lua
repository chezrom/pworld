local Class=require 'lib.hc.class'
local GridPlacer = Class{}
local default= {row=1,col=1,rowspan=1,colspan=1,xalign='center',yalign='center',border=2,expend=false}

function GridPlacer:construct()
	self.rowMin=math.huge
	self.rowMax=-math.huge
	self.colMin=math.huge
	self.colMax=-math.huge
	self.cells={}
	self.resolved=false
end

function GridPlacer:add(comp,params)
	local cd=params or {}
	for k,v in pairs(default) do
		if not cd[k] then cd[k]=v end
	end
	local r,c=cd.row,cd.col
	self.rowMin = math.min(self.rowMin,r)
	self.colMin = math.min(self.colMin,c)
	self.rowMax = math.max(self.rowMax,r)
	self.colMax = math.max(self.colMax,c)
	cd.comp=comp
	table.insert(self.cells,cd)
	self.resolved=false
end

function GridPlacer:resolve()
	local widths,heights,wc,hc={},{},{},{}
	
	-- first step : determine minimal width and height for each col and row
	for _,cd in ipairs(self.cells) do
		local r,c = cd.row,cd.col
		local h = cd.comp.h + 2*cd.border
		local w = cd.comp.w + 2*cd.border
		if cd.colspan==1 then
			widths[c] = math.max(widths[c] or 0,w)
		else
			local id= c.."/"..cd.colspan
			cd.wcid=id
			wc[id] = math.max(wc[id] or 0,w)
		end
		if cd.rowspan==1 then
			heights[r] = math.max(heights[r] or 0,h)
		else
			local id= r.."/"..cd.rowspan
			cd.hcid=id
			hc[id] = math.max(hc[id] or 0,w)
		end
	end

	-- second step : resolve multi-row and multi-col constraints
	for id,minw in pairs(wc) do
		local c,nc = string.match(id,"(%d+)/(%d+)")
		local w=0
		for ic = c,c+nc-1 do
			w = w + (widths[ic] or 0)
		end
		if w < minw then
		
		end
	end
	
	for id,minh in pairs(hc) do
		local r,nr = string.match(id,"(%d+)/(%d+)")
		local h=0
		for ir = r,r+nr-1 do
			h = h + (heights[ir] or 0)
		end
		if h < minh then
		
		end
	end
	
	-- third step : determination of x and y for col and row
	local x,y={},{}
	x[self.colMin]=0
	y[self.rowMin]=0

	for c = self.colMin+1,self.colMax do
		x[c] = x[c-1] + (widths[c-1] or 0)
	end

	for r = self.rowMin+1,self.rowMax do
		y[r] = y[r-1] + (heights[r-1] or 0)
	end
	
	self.w = x[self.colMax] + (widths[self.colMax] or 0)
	self.h = y[self.rowMax] + (heights[self.rowMax] or 0)
	

	-- fourth step : determination of x and y of each comp
	for _,cd in ipairs(self.cells) do
		local bx,by=x[cd.col]+cd.border,y[cd.row]+cd.border
		
		local tw,th=(widths[cd.col] or 0)-2*cd.border,(heights[cd.row] or 0)-2*cd.border
		
		if cd.colspan then
			for ic=cd.col+1,cd.col+cd.colspan-1 do
				tw=tw+(widths[ic] or 0)
			end
		end
		
		if cd.rowspan then
			for ir=cd.row+1,cd.row+cd.rowspan-1 do
				th=th+(heights[ir] or 0)
			end
		end

		if cd.expend and cd.comp.expend then
			if tw > cd.comp.w or th > cd.comp.h then
				cd.comp:expend(tw,th)
			end
		end	
		
		local gx,gy
		
		local xalign=cd.xalign
		if xalign=='left' then
			gx=bx
		elseif xalign=='right' then
			gx=bx+tw-cd.comp.w
		else
			-- default : center
			gx=bx + math.floor((tw-cd.comp.w)/2)
		end
		
		local yalign=cd.yalign
		if yalign=='up' then
			gy=by
		elseif yalign=='down' then
			gy=by+th-cd.comp.h
		else
			-- default : center
			gy=by+math.floor((th-cd.comp.h)/2)
		end
		
		cd.gx,cd.gy=gx,gy
	end
	self.resolved=true
end

function GridPlacer:inject(parent,border) 
	border = border or 0
	if not self.resolved then self:resolve() end
	for _,cd in ipairs(self.cells) do
		cd.comp.x=cd.gx+border
		cd.comp.y=cd.gy+border
		parent:add(cd.comp)
	end
	parent:setDimension(self.w+2*border,self.h+2*border)
end

return GridPlacer