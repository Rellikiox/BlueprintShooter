-- Obstacle
require( 'entities/entity' )

Obstacle = class( "Obstacle", Entity )

Obstacle.static.color = { 0, 0, 0, 255 }

function Obstacle:initialize( x, y, w, h )
	self.pos = Vec2:new( x, y )
	self.w = w
	self.h = h
	self.points = {
		Vec2:new( self.pos.x, 			self.pos.y ),
		Vec2:new( self.pos.x + self.w,	self.pos.y ),
		Vec2:new( self.pos.x + self.w, 	self.pos.y + self.h ),
		Vec2:new( self.pos.x, 			self.pos.y + self.h )
	}
end

function Obstacle:draw( )
	love.graphics.setColor( unpack( Obstacle.color ) )
	love.graphics.rectangle( "fill", self.pos.x, self.pos.y, self.w, self.h )
end

function Obstacle:pointsFacing( point )

	lineSide = function ( a, b, p )
		return (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x)
	end
	
	getNext = function ( list, key )
		if key == #list then
			return list[1]
		else
			return list[key + 1]
		end
	end
	
	local points = {}
	local pos_end = self.points[1]
	local pos_key = 0
	local neg_end = self.points[1]
	local neg_key = 0
	
	for k, val in pairs( self.points ) do
		if lineSide( point, pos_end, val ) >= 0 then
			pos_end = val
			pos_key = k
		elseif lineSide( point, neg_end, val ) <= 0 then
			neg_end = val
			neg_key = k
		end
	end
	if getNext( self.points, pos_key ) == neg_end then
		return { pos_end, neg_end }
	else
		return { pos_end, getNext( self.points, pos_key ), neg_end }
	end
end

function Obstacle:getAABB( )
	return AABB( Vec2( self.pos.x + self.w / 2, self.pos.y + self.h / 2 ), Vec2( self.w / 2, self.h / 2 ) )
end

