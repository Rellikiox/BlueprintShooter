-- Entity Manager

require( 'misc/QuadTree' )	

EntityManager = class( "EntityManager" )

function EntityManager:initialize( )
	self.entities = {}
	self.QT = QuadTree( AABB( Vec2( 400, 300 ), Vec2( 400, 300 ) ), 1 )
	self.entity_count = 0
end

function EntityManager:add( klass, ... )
	
	ent = klass( unpack( arg ) )
	ent.id = self.entity_count
	self.entity_count = self.entity_count + 1
	if not self.entities[ klass ] then
		self.entities[ klass ] = { ent }
	else
		table.insert( self.entities[ klass ], ent )
	end
	if klass == Wall then
		self.QT:insert( ent, ent:getAABB() )
	end
	
	return ent
end

function EntityManager:getEntitiesByClass( klass )
	return self.entities.klass
end

function EntityManager:getEntitiesInside( range )
	return self.QT:query( range )
end

function EntityManager:update( dt )
	for k1, entList in pairs( self.entities ) do
		for k2, ent in pairs( entList ) do
			if ent.update then
				ent:update( dt )
			end
		end
	end
end

function EntityManager:draw( )
	for k1, entList in pairs( self.entities ) do
		for k2, ent in pairs( entList ) do
			if ent.drawBG then
				ent:drawBG( )
			end
		end
	end
	for k1, entList in pairs( self.entities ) do
		for k2, ent in pairs( entList ) do
			if ent.draw then
				ent:draw( )
			end
		end
	end
	love.graphics.setColor( 0, 255, 0, 100 )
	self.QT:draw()
end