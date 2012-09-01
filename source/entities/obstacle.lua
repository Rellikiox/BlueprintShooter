-- Obstacle

Obstacle = class( "Obstacle" )

Obstacle.static.color = { 0, 0, 0, 255 }

function Obstacle:initialize( x, y, w, h )
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.points = {
		{ x = self.x, 			y = self.y },
		{ x = self.x + self.w, 	y = self.y },
		{ x = self.x + self.w, 	y = self.y + self.h },
		{ x = self.x, 			y = self.y + self.h }
	}
end

function Obstacle:draw( )
	love.graphics.setColor( unpack( Obstacle.color ) )
	love.graphics.rectangle( "fill", self.x, self.y, self.w, self.h )
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
	
	return { pos_end, getNext( self.points, pos_key ), neg_end }
end

