-- Wall
require( 'entities/entity' )

Wall = class( "Wall", Entity )

Wall.static.color = { 233, 247, 255, 255 }

function Wall:initialize( x, y, w, h )
	self.pos = Vec2:new( x, y )
	self.w = w
	self.h = h
	self.points = {
		Vec2:new( self.pos.x, 			self.pos.y ),
		Vec2:new( self.pos.x + self.w,	self.pos.y ),
		Vec2:new( self.pos.x + self.w, 	self.pos.y + self.h ),
		Vec2:new( self.pos.x, 			self.pos.y + self.h )
	}
	self.shape = Collider:addRectangle( self.pos.x, self.pos.y, self.w, self.h )
	self.shape.parent = self
	Collider:setPassive(self.shape)
	Collider:addToGroup("walls", self.shape)
	
	local grid_tile_img = RM:getImage( "Wall_background_tile" )
	local tile_width = grid_tile_img:getWidth()
	local tile_height = grid_tile_img:getHeight()
	local grid_tile = love.graphics.newQuad( 0, 0, tile_width, tile_height, tile_width, tile_height )
	
	local hor_tiles = math.ceil( self.w / tile_width )
	local ver_tiles = math.ceil( self.h / tile_height )
	
	local x_offset = math.mod( self.pos.x, tile_width )
	local y_offset = math.mod( self.pos.y, tile_height )
	
	self.background_batch = love.graphics.newSpriteBatch( grid_tile_img, (hor_tiles + 1) * (ver_tiles + 1))
	for i = 1, hor_tiles, 1 do
		for j = 1, ver_tiles, 1 do
			self.background_batch:addq( grid_tile, self.pos.x + (i - 1) * tile_width - x_offset, self.pos.y + (j - 1) * tile_height - y_offset )
		end
	end
	
	self.stencil_func = function () 
		love.graphics.rectangle( "fill", self.pos.x, self.pos.y, self.w, self.h )
	end
	
end

function Wall:drawBG( )
	--love.graphics.setStencil( self.stencil_func )
	
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.setLineWidth( 2 )
	love.graphics.rectangle( "line", self.pos.x, self.pos.y, self.w, self.h )
	love.graphics.setLineWidth( 1 )
	
	--love.graphics.setStencil( )
end

function Wall:draw( )
	love.graphics.setStencil( self.stencil_func )

	love.graphics.setColor( 46,48,148 )
	love.graphics.rectangle( "fill", self.pos.x + 2, self.pos.y + 2, self.w - 4, self.h - 4)
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( self.background_batch )

	love.graphics.setStencil( )
end

function Wall:onCollision( other, dx, dy )
	
end

function Wall:pointsFacing( point )

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

function Wall:getAABB( )
	return AABB( Vec2( self.pos.x + self.w / 2, self.pos.y + self.h / 2 ), Vec2( self.w / 2, self.h / 2 ) )
end

function Wall:getCenter( )
	return Vec2( self.pos.x + self.w / 2, self.pos.y + self.h / 2 )
end
