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
	local angle = math.atan2( self.y, self.x )
	if vec then
		angle = math.atan2( vec.y, vec.x ) - angle
	end
	if angle < 0 then angle = angle + math.pi * 2 end
	return angle
end

function Vec2:AngleDeg( vec )
	return math.deg( self:AngleRad( vec ) )
end

function Vec2:Multiply( factor )
	self.x = self.x * factor
	self.y = self.y * factor
end
