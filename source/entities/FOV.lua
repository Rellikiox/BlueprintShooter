-- FOV

FOV = class( "FOV", Entity )

FOV.static.segment_length = 15

FOV.static.getAng = function ( a, b, p )
	local ab = b - a
	local ap = p - a
	local val = math.mod( math.atan2( ap.y, ap.x ) - math.atan2( ab.y, ab.x ), math.pi )
	if val < 0 then val = val + math.pi end
	return val
end

function FOV:insertPoints ( p11, p12, p21, p22, p3 ) 	
	local found = false
	local i = 1
	while i <= #self.segment_points do
		if found then
			if self.segment_points[ i ].val > p11.val then
				table.insert( self.segment_points, i , p12)
				table.insert( self.segment_points, i + 1, p11 )
				print( "Coloco el segundo en la pos " .. i )
				break
			else
				table.remove( self.segment_points, i )
				print( "Borro" )
				--i = i + 1
			end
		else
			if self.segment_points[ i ].val > p21.val then -- colocamos el primero
				table.insert( self.segment_points, i, p21 )
				table.insert( self.segment_points, i + 1, p22 )
				found = true
				print( "Coloco el primero en la pos " .. i )
				if p3 then
					table.insert( self.segment_points, i + 2, p3 )
					i = i + 3
				else
					i = i + 2
				end
			else
				i = i + 1
				print( "Avanzo" )
			end
		end				
	end
end

function FOV:initialize( owner, size, aperture, color )
	self.owner = owner
	self.pos = Vec2( owner.pos.x, owner.pos.y )
	self.rot = self.owner.rot
	self.aperture = aperture
	self.size = size
	self.color = color
	self.segment_points = {}
	self.oclusing_segments = { }
	self.shadow_points = { }
	self:calculateSegments()
end

function FOV:calculateSegments( )
	self.segment_points = { }
	self.tl = Vec2( self.owner.pos.x, self.owner.pos.y )
	self.br = Vec2( self.owner.pos.x, self.owner.pos.y )
	local new_ang = self.rot - self.aperture / 2
	
	for i = 0, math.ceil( self.aperture / FOV.segment_length ) do
		local x1 = self.pos.x + self.size * math.cos( math.rad(new_ang) )
		local y1 = self.pos.y + self.size * math.sin( math.rad(new_ang) )
		new_ang = new_ang + FOV.segment_length
		
		self.segment_points[ i + 1 ] = Vec2( x1, y1 )
		
		-- Keep track of left top bottom right
		self.tl.x = math.min( self.tl.x, x1 )
		self.tl.y = math.min( self.tl.y, y1 )
		self.br.x = math.max( self.br.x, x1 )
		self.br.y = math.max( self.br.y, y1 )
	end
	
	for k, v in pairs( self.segment_points ) do
		v.val = FOV.getAng( self.pos, self.segment_points[1], v)
	end
	
	for k1, v1 in ipairs( self.segment_points ) do
		print( k1 .. " -> " .. v1.val )
	end
end

function FOV:queryObjects( )
	local half = Vec2( (self.br.x - self.tl.x) / 2, (self.br.y - self.tl.y) / 2 )
	local center = self.tl + half
	self.visible_shapes = EM:getEntitiesInside( AABB( center, half ) )
	
	for k1, v1 in pairs( self.visible_shapes ) do
		local inside_fov = false
		for k2, v2 in pairs( v1.points ) do
			local vec = v2 - self.pos
			local ang = math.deg( math.atan2( vec.y, vec.x ) )
			if ang >= ( self.rot - self.aperture / 2 ) and ang <= ( self.rot + self.aperture / 2 ) and vec:Length() <= self.size then
				inside_fov = true
				break
			end
		end
		if not inside_fov then
			self.visible_shapes[ k1 ] = nil
		end
	end
	self.shadow_points = { }
	for k, v in pairs( self.visible_shapes ) do
		v:pointsFacing( self.pos )
		local point_list = v:pointsFacing( self.pos )
		if #point_list == 2 then
			
			local dir1 = point_list[1] - self.pos
			dir1:Normalize()
			local p1 = Vec2( self.pos.x + dir1.x * self.size, self.pos.y + dir1.y * self.size )
			p1.val = FOV.getAng( self.pos, self.segment_points[1], p1)
			point_list[1].val = p1.val + 0.00001
			
			local dir2 = point_list[2] - self.pos
			dir2:Normalize()
			local p2 = Vec2( self.pos.x + dir2.x * self.size, self.pos.y + dir2.y * self.size )
			p2.val = FOV.getAng( self.pos, self.segment_points[1], p2)
			point_list[2].val = p2.val - 0.00001
			
			self:insertPoints( p1, point_list[1], p2, point_list[2] )

		else -- #point_list == 3
		
			local dir1 = point_list[1] - self.pos
			dir1:Normalize()
			local p1 = Vec2( self.pos.x + dir1.x * self.size, self.pos.y + dir1.y * self.size )
			p1.val = FOV.getAng( self.pos, self.segment_points[1], p1)
			point_list[1].val = p1.val + 0.00001
			
			local dir2 = point_list[3] - self.pos
			dir2:Normalize()
			local p2 = Vec2( self.pos.x + dir2.x * self.size, self.pos.y + dir2.y * self.size )
			p2.val = FOV.getAng( self.pos, self.segment_points[1], p2)
			point_list[3].val = p2.val - 0.00001
			
			self:insertPoints( p1, point_list[1], p2, point_list[3], point_list[ 2 ] )
		
		end
		
		for k2, v2 in pairs( point_list ) do
			local dir = v2 - self.pos
			dir:Normalize()
			table.insert( self.shadow_points, Vec2( self.pos.x + dir.x * self.size, self.pos.y + dir.y * self.size ) )
		end
	end
end

function FOV:draw( )
	-- Filling of the FOV
	self.color[ 4 ] = 100
	love.graphics.setColor( unpack( self.color ) )
	for i = 1, #self.segment_points - 1 do
		local p1 = self.segment_points[ i ]
		local p2 = self.segment_points[ i + 1 ]
		love.graphics.triangle( "fill", self.pos.x, self.pos.y, p1.x, p1.y, p2.x, p2.y )
	end
	
	-- Border of the FOV
	self.color[ 4 ] = 255
	love.graphics.setColor( unpack( self.color ) )
	love.graphics.line( self.pos.x, self.pos.y, self.segment_points[1].x, self.segment_points[1].y )
	for i = 1, #self.segment_points - 1 do
		local p1 = self.segment_points[ i ]
		local p2 = self.segment_points[ i + 1 ]
		love.graphics.line( p1.x, p1.y, p2.x, p2.y )
	end
	love.graphics.line( self.pos.x, self.pos.y, self.segment_points[#self.segment_points].x, self.segment_points[#self.segment_points].y )
	
	for k, v in pairs( self.shadow_points ) do
		--love.graphics.line( self.pos.x, self.pos.y, v.x, v.y )
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
		self:calculateSegments()
		self:queryObjects()
	end
	
	if control.tap.attack then
		self:queryObjects()
	end
end