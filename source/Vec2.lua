-- Vec2

Vec2 = class( "Vec2" )

function Vec2:initialize( x, y )
	self.x = x
	self.y = y
end

function Vec2:__add( v )
	return Vec2( self.x + v.x, self.y + v.y )
end

function Vec2:__sub( v )
	return Vec2( self.x - v.x, self.y - v.y )
end

function Vec2:__tostring( )
	return "(" .. self.x .. ", " .. self.y .. ")"
end

function Vec2:__concat( v )
	return self:__tostring() .. v:__tostring()
end

function Vec2:Length( )
	return math.sqrt( self.x * self.x + self.y * self.y )
end

function Vec2:LengthSqrd( )
	return self.x * self.x + self.y * self.y
end

function Vec2:Normalize( )
	local size = self:Length()
	self.x = self.x / size
	self.y = self.y / size
end

function Vec2:AngleRad( vec )
	if vec then
		return math.atan2( vec.y, vec.x ) - math.atan2( self.y, self.x )
	end
	return math.atan2( self.y, self.x )
end

function Vec2:AngleDeg( vec )
	if vec then
		return math.deg( math.atan2( vec.y, vec.x ) - math.atan2( self.y, self.x ) )
	end
	return math.deg( math.atan2( self.y, self.x ) )
end
