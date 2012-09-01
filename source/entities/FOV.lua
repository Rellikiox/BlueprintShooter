-- FOV

FOV = class( "FOV", Entity )

FOV.static.segment_length = 15

function FOV:initialize( owner, size, aperture, color )
	self.owner = owner
	self.pos = Vec2( owner.pos.x, owner.pos.y )
	self.rot = self.owner.rot
	self.aperture = aperture
	self.size = size
	self.color = color
	self.segment_points = {}
	self.tl = Vec2( owner.pos.x, owner.pos.y )
	self.br = Vec2( owner.pos.x, owner.pos.y )
	self.visible_shapes = { }
	self:calculateSegments()
end

function FOV:calculateSegments( )
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
		self.br.x = math.max( self.br.x, y1 )
	end
end

function FOV:queryObjects( )
	--self.visible_shapes = nil
	local half = Vec2( (self.br.x - self.tl.x) / 2, (self.br.y - self.tl.y) / 2 )
	local center = self.tl + half
	print( #EM:getEntitiesInside( AABB( center, half ) ) )
	for k, v in pairs( self.visible_shapes ) do
		print( v )
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
	end
	
	if control.tap.attack then
		self:queryObjects()
	end
end