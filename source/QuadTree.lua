-- QuadTree

QuadTree = class( "QuadTree" )

QuadTree.static.MAX_DEPTH = 4
function QuadTree:initialize( boundary, depth )
	self.boundary = boundary
	self.divided = false
	self.depth = depth
	self.nw = nil
	self.ne = nil
	self.se = nil
	self.sw = nil
	self.elements = { }
	self.elements_regions = { }
end

function QuadTree:insert( element, bbox )
	if not self.boundary:intersects( bbox ) then
		return false
	end
	
	if self.depth == QuadTree.MAX_DEPTH then
		table.insert( self.elements, element )
		table.insert( self.elements_regions, bbox )
		return true
	end
	
	if not self.divided then
		self:subdivide()
	end
	
	if self.nw.boundary:intersects( bbox ) then
		self.nw:insert( element, bbox )
	elseif self.ne.boundary:intersects( bbox ) then
		self.ne:insert( element, bbox )
	elseif self.se.boundary:intersects( bbox ) then
		self.se:insert( element, bbox )
	elseif self.sw.boundary:intersects( bbox ) then
		self.sw:insert( element, bbox )
	end
	
	return true
end

function QuadTree:query( range ) -- I hate recursion
	local elements = { }
	
	if not self.divided then
		for k, v in pairs( self.elements_regions ) do
			if v:intersects( range ) then
				table.insert( elements, self.elements[ k ] )
			end
		end
	else	
		if self.nw.boundary:intersects( range ) then
			for k, v in pairs( self.nw:query( range ) ) do
				table.insert( elements, v )
			end
		end
		if self.ne.boundary:intersects( range ) then
			for k, v in pairs( self.ne:query( range ) ) do
				table.insert( elements, v )
			end
		end
		if self.se.boundary:intersects( range ) then
			for k, v in pairs( self.se:query( range ) ) do
				table.insert( elements, v )
			end
		end
		if self.sw.boundary:intersects( range ) then
			for k, v in pairs( self.sw:query( range ) ) do
				table.insert( elements, v )
			end
		end
	end
	
	return elements
end

function QuadTree:subdivide( )
	self.divided = true
	
	local new_half = Vec2( self.boundary.half.x / 2, self.boundary.half.y / 2 )
	
	local nw_pos = self.boundary.center - new_half
	local nw_aabb = AABB( nw_pos, new_half )
	self.nw = QuadTree( nw_aabb, self.depth + 1 )
	
	local ne_pos = Vec2( nw_pos.x + self.boundary.half.x, nw_pos.y )
	local ne_aabb = AABB( ne_pos, new_half )
	self.ne = QuadTree( ne_aabb, self.depth + 1 )
	
	local se_pos = self.boundary.center + new_half
	local se_aabb = AABB( se_pos, new_half )
	self.se = QuadTree( se_aabb, self.depth + 1 )
	
	local sw_pos = Vec2( nw_pos.x, nw_pos.y + self.boundary.half.y )
	local sw_aabb = AABB( sw_pos, new_half )
	self.sw = QuadTree( sw_aabb, self.depth + 1 )
end

function QuadTree:draw( )
	love.graphics.line( self.boundary.center.x - self.boundary.half.x, self.boundary.center.y, self.boundary.center.x + self.boundary.half.x, self.boundary.center.y )
	love.graphics.line( self.boundary.center.x, self.boundary.center.y - self.boundary.half.y, self.boundary.center.x, self.boundary.center.y + self.boundary.half.y )
	if self.divided then
		self.nw:draw()
		self.ne:draw()
		self.se:draw()
		self.sw:draw()
	end
end

-- AABB

AABB = class( "AABB" )

function AABB:initialize( center, half )
	self.center = center
	self.half = half
end

function AABB:contains( point )
	local min_point = self.center - self.half
	if ( point.x >= min_point.x and point.y >= min.point.x ) then
		local max_point = self.center + self.half
		return point.x <= max_point.x and point.y <= max_point.y
	end
	return false
end

function AABB:intersects( region )
	local diff_x = math.abs(self.center.x - region.center.x);
	local diff_y = math.abs(self.center.y - region.center.y);

	return diff_x < (self.half.x + region.half.x) and diff_y < (self.half.y + region.half.y)
end

function AABB:__tostring( )
	return "Center " .. self.center .. " Half " .. self.half
end


