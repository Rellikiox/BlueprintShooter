-- FOV

FOV = class( "FOV", Entity )

function FOV:initialize( owner, size, aperture, color )
	self.owner = owner
	self.pos = Vec2( owner.pos.x, owner.pos.y )
	self.rot = self.owner.rot
	self.aperture = aperture
	self.size = size
	self.color = color
	self.segment_length = 1
	self.segment_points = {}
	self.close_segment_points = {}
	self:calculateSegments()
	self.entities_in_sight = 0
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
		new_ang = new_ang + self.segment_length
		
		self.segment_points[ i ] = Vec2( x1, y1 )
		self.close_segment_points[ i ] = Vec2( x0, y0 )
		
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

	-- Cull objects outside FOV
	--[[
	local start_vec = self.segment_points[1] - self.pos
	for k1, v1 in pairs( visible_shapes ) do
		local inside_fov = false
		for k2, v2 in pairs( v1.points ) do
			local vec = v2 - self.pos
			local ang = start_vec:AngleDeg( vec )
			if ang < 0 then ang = ang + 360 end
			
			if ang <= self.aperture and vec:Length() <= self.size then
				inside_fov = true					
				break
			end
		end
		if not inside_fov then
			visible_shapes[ k1 ] = nil
		end
	end
	--]]
	self.entities_in_sight = #visible_shapes
	
	local count = 0
	for k in pairs(visible_shapes) do
	print(k)
		count = count + 1
	end
	--print (count)
	
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

function FOV:draw( )
	-- Filling of the FOV
	self.color[ 4 ] = 100
	love.graphics.setColor( unpack( self.color ) )
	for i = 1, #self.segment_points - 1 do
		local p0 = self.close_segment_points[ i ]
		local p1 = self.segment_points[ i ]
		local p2 = self.segment_points[ i + 1 ]
		local p3 = self.close_segment_points[ i + 1 ]
		love.graphics.polygon( "fill", p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y )
	end
	
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
		self:queryObjects()
		if debug_on then
			print( "Query objects: " .. timer:getElapsedMicroseconds() )
		end
	end
end