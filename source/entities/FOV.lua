-- FOV

FOV = class( "FOV", Entity )

function FOV:initialize( owner, size, aperture, color )
	self.owner = owner
	self.pos = Vec2( owner.pos.x, owner.pos.y )
	self.rot = self.owner.rot
	self.aperture = aperture
	self.size = size
	self.color = color
	self.segment_length = 6
	self.segment_points = {}
	self.close_segment_points = {}
	self:calculateSegments()
	self.entities_in_sight = 0
	
	self.prov_list = { }
	self.arc_points = { }
	self.debug_draw = { }
end

function FOV:calculateSegments( )
	self.segment_points = { }
	self.close_segment_points = { }
	self.tl = Vec2( self.owner.pos.x, self.owner.pos.y )
	self.br = Vec2( self.owner.pos.x, self.owner.pos.y )
	
	local new_ang = self.rot - self.aperture / 2
	for i = 1, math.ceil( self.aperture / self.segment_length ) + 1 do
		local aux_cos = math.cos( math.rad(new_ang) )
		local aux_sin = math.sin( math.rad(new_ang) )
		local x1 = self.pos.x + self.size * aux_cos
		local y1 = self.pos.y + self.size * aux_sin
		local x0 = self.pos.x + Player.radius * aux_cos
		local y0 = self.pos.y + Player.radius * aux_sin

		local point = Vec2( x1, y1 )
		point.ang = (i - 1) * self.segment_length
		self.segment_points[ i ] = point
		self.close_segment_points[ i ] = Vec2( x0, y0 )		
		
		new_ang = new_ang + self.segment_length
		
		-- Keep track of left top bottom right
		self.tl.x = math.min( self.tl.x, x1 )
		self.tl.y = math.min( self.tl.y, y1 )
		self.br.x = math.max( self.br.x, x1 )
		self.br.y = math.max( self.br.y, y1 )
	end
end

function FOV:queryObjects( )
	local half = Vec2( (self.br.x - self.tl.x) / 2, (self.br.y - self.tl.y) / 2 )
	local center = self.tl + half
	local visible_shapes = EM:getEntitiesInside( AABB( center, half ) )
	
	if debug_on then
		local count = 0
		for k in pairs(visible_shapes) do
			count = count + 1
		end
		self.entities_in_sight = count
	end	
	
	-- Cast rays
	for k1, v1 in pairs( self.segment_points ) do
		best_dist = 1
		local dir = v1 - self.pos
		for k2, v2 in pairs( visible_shapes ) do
			local hit, t = v2.shape:intersectsRay( self.pos.x, self.pos.y, dir.x, dir.y )
			if hit and t < best_dist then
				best_dist = t
			end
		end
		if best_dist < 1 then
			self.segment_points[ k1 ] = Vec2( self.pos.x + dir.x * best_dist, self.pos.y + dir.y * best_dist )
		end
	end
end

function hasVision( p1, p2, objects )
	local dir = p2 - p1
	for k, v in pairs( objects ) do
		local hit, t = v.shape:intersectsRay( p1.x, p1.y, dir.x, dir.y )
		if hit and t < 1 then
			return false, Vec2( p1.x + dir.x * t, p1.y + dir.y * t )
		end
	end
	return true
end

function extractPoints( list )
	if #list >= 2 then
		local end1 = list[ 1 ]
		local end2 = list[ #list ]
		local inter = { }
		for i = 2, #list - 1 do
			table.insert( inter, list[ i ] )
		end		
		return end1, inter, end2
	end
end

function FOV:projectPoint( point, objects, current_shape )
	local dir = point - self.pos
	local point_angle = dir:AngleRad()
	local point_in_arc = Vec2( self.pos.x + math.cos( point_angle ) * self.size, self.pos.y + math.sin( point_angle ) * self.size )
	dir = point_in_arc - point
	
	local best_dist = 1
	for k, v in pairs( objects ) do
		if v ~= current_shape then
			local hit, t = v.shape:intersectsRay( point.x, point.y, dir.x, dir.y )
			if hit and t < best_dist then
				best_dist = t
			end
		end
	end
	local projected_point = Vec2( point.x + dir.x * best_dist, point.y + dir.y * best_dist )
	projected_point.ang = point_angle
	return projected_point, best_dist == 1
end

function FOV:queryObjects2( )
	local half = Vec2( (self.br.x - self.tl.x) / 2, (self.br.y - self.tl.y) / 2 )
	local center = self.tl + half
	local visible_shapes = EM:getEntitiesInside( AABB( center, half ) )
	self.prov_list = { }
	self.arc_points = { }
	self.debug_draw = { }
	local erasing = false
	local first_vec = self.segment_points[ 1 ] - self.pos
	
	if debug_on then
		local count = 0
		for k in pairs(visible_shapes) do
			count = count + 1
		end
		self.entities_in_sight = count
	end	
	
	-- Check if any point lies inside a obstacle
	
	for k1, v1 in pairs( self.segment_points ) do
		local inside = false
		local object = nil
		for k2, v2 in pairs( visible_shapes ) do
			if v2.shape:contains( v1.x, v1.y ) then
				inside = true
				object = v2
				break
			end
		end
		if inside then
			local point = v1
			if k1 > 1 then
				local prev_point = self.segment_points[ k1 - 1 ]
				local vis, col = hasVision( prev_point, point, { object } )
				if not vis then
					if hasVision( self.pos, col, { object } ) then
						col.ang = first_vec:AngleDeg( (col - self.pos) )
						table.insert( self.arc_points, col )
					end
				end
			end
			if k1 < #self.segment_points then
				local next_point = self.segment_points[ k1 + 1 ]
				local vis, col = hasVision( next_point, point, { object } )
				if not vis then
					if hasVision( self.pos, col, { object } ) then
						col.ang = first_vec:AngleDeg( (col - self.pos) )
						table.insert( self.arc_points, col )
					end
				end
			end
			table.remove( self.segment_points, k1 )
		end
	end
	
	local vision, coll_point = hasVision( self.pos, self.segment_points[ 1 ], visible_shapes )
	if not vision then
		coll_point.ang = 0
		table.insert( self.debug_draw, coll_point)
		table.insert( self.prov_list, coll_point )
		erasing = true
	end
	
	vision, coll_point = hasVision( self.pos, self.segment_points[ #self.segment_points ], visible_shapes )
	if not vision then
		coll_point.ang = self.aperture
		table.insert( self.debug_draw, coll_point)
		table.insert( self.prov_list, coll_point )
	end
	

	for k1, v1 in pairs( visible_shapes ) do
		local extr_der, intermediate, extr_izq = extractPoints( v1:pointsFacing( self.pos ) )
		
		if hasVision( self.pos, extr_der, visible_shapes ) and (extr_der - self.pos):Length() <= self.size then
			extr_der.ang = first_vec:AngleDeg( (extr_der - self.pos) )
			table.insert( self.prov_list, extr_der )
			local new_point, in_arc = self:projectPoint( extr_der, visible_shapes, v1 )
			new_point.ang = extr_der.ang + 0.0001
			if in_arc then
				table.insert( self.arc_points, new_point )
			else
				table.insert( self.prov_list, new_point )
			end
			
			table.insert( self.debug_draw, new_point )
			table.insert( self.debug_draw, extr_der )
		end
		if hasVision( self.pos, extr_izq, visible_shapes ) and (extr_izq - self.pos):Length() <= self.size  then
			extr_izq.ang = first_vec:AngleDeg( (extr_izq - self.pos) )
			table.insert( self.prov_list, extr_izq )
			local new_point, in_arc = self:projectPoint( extr_izq, visible_shapes, v1 )
			new_point.ang = extr_izq.ang - 0.0001
			if in_arc then
				table.insert( self.arc_points, new_point )
			else
				table.insert( self.prov_list, new_point )
			end
			
			table.insert( self.debug_draw, extr_izq )
			table.insert( self.debug_draw, new_point )
		end	
		for k2, v2 in pairs( intermediate ) do
			local vec = v2 - self.pos
			if vec:Length() <= self.size then
				v2.ang = first_vec:AngleDeg( vec )
				table.insert( self.prov_list, v2 )
				table.insert( self.debug_draw, v2 )
			end
		end
	end
	
	table.sort( self.arc_points, function ( a, b ) return a.ang < b.ang end )
	table.sort( self.prov_list, function ( a, b ) return a.ang < b.ang end )
	
	local i, j = 1, 1
	local max_i, max_j = #self.segment_points, #self.arc_points
	
	while i <= max_i and j <= max_j do
		if self.arc_points[ j ].ang < self.segment_points[ i ].ang then
			erasing = not erasing
			table.insert( self.segment_points, i, self.arc_points[ j ] )
			j = j + 1
			i = i + 1
			max_i = max_i + 1
		elseif erasing then
			table.remove( self.segment_points, i )
			max_i = max_i - 1
		else
			i = i + 1
		end		
	end
	
	local i, j = 1, 1
	local max_i, max_j = #self.segment_points, #self.prov_list
	while i <= max_i and j <= max_j do
		if self.prov_list[ j ].ang < self.segment_points[ i ].ang then
			table.insert( self.segment_points, i, self.prov_list[ j ] )
			j = j + 1
			max_i = max_i + 1
		end
		i = i + 1
	end
	while j <= max_j and self.prov_list[ j ].ang <= self.aperture do
		table.insert( self.segment_points, self.prov_list[ j ] )
		j = j + 1
	end
end

function drawX( p )
	love.graphics.line( p.x - 3, p.y - 3, p.x + 3, p.y + 3 )
	love.graphics.line( p.x - 3, p.y + 3, p.x + 3, p.y - 3 )
end

function FOV:draw( )
	-- Filling of the FOV
	--[[
	self.color[ 4 ] = 100
	love.graphics.setColor( unpack( self.color ) )
	for i = 1, #self.segment_points - 1 do
		local p0 = self.close_segment_points[ i ]
		local p1 = self.segment_points[ i ]
		local p2 = self.segment_points[ i + 1 ]
		local p3 = self.close_segment_points[ i + 1 ]
		love.graphics.polygon( "fill", p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y )
	end
	--]]
	-- Border of the FOV
	self.color[ 4 ] = 255
	love.graphics.setColor( unpack( self.color ) )
	love.graphics.line( self.close_segment_points[1].x, self.close_segment_points[1].y, self.segment_points[1].x, self.segment_points[1].y )
	for i = 1, #self.segment_points - 1 do
		local p1 = self.segment_points[ i ]
		local p2 = self.segment_points[ i + 1 ]
		love.graphics.line( p1.x, p1.y, p2.x, p2.y )
	end
	love.graphics.line( self.close_segment_points[#self.close_segment_points].x, self.close_segment_points[#self.close_segment_points].y, self.segment_points[#self.segment_points].x, self.segment_points[#self.segment_points].y )
	
	if debug_on then
		love.graphics.rectangle( "line", self.tl.x, self.tl.y, self.br.x - self.tl.x, self.br.y - self.tl.y )
		love.graphics.print( self.entities_in_sight, self.pos.x + 10, self.pos.y )
		love.graphics.setColor( 255, 255, 255 )
		for k, v in pairs( self.prov_list ) do
			drawX( v )
			love.graphics.print( k, v.x + 5, v.y + 5 )
		end
		love.graphics.setColor( 255, 0, 0 )
		for k, v in pairs( self.segment_points ) do
			drawX( v )
			--love.graphics.print( k, v.x + 5, v.y + 15 )
			love.graphics.print( math.floor( v.ang ) , v.x + 5, v.y + 25 )
		end
	end
end

function FOV:update( dt )
	local change = false
	if self.pos.x ~= self.owner.pos.x or self.pos.y ~= self.owner.pos.y or self.rot ~= self.owner.rot then
			change = true
	end
	self.pos.x = self.owner.pos.x
	self.pos.y = self.owner.pos.y
	self.rot = self.owner.rot
	if change then
		local timer = Clock()
		self:calculateSegments()
		self:queryObjects2()

		if debug_on then
			print( "Query objects: " .. timer:getElapsedMicroseconds() )
		end
	end
end