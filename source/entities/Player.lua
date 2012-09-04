-- Player

Player = class( "Player", Entity )

Player.static.radius = 10
Player.static.speed = 100
Player.static.color = { 255, 0, 0 }

function Player:initialize( x, y )
	require( 'entities/FOV' )
	self.pos = Vec2:new( x, y )
	self.vel = Vec2:new( 0, 0 )
	self.rot = 0
	
	EM:add( FOV, self, 200, 90, Player.color )
end

function Player:checkInput( )
	if control.left and not control.right then -- Going Left
		self.vel.x = -Player.speed
	elseif control.right and not control.left then -- Going Right
		self.vel.x = Player.speed
	else
		self.vel.x = 0
	end
	
	if control.up and not control.down then -- Going Up
		self.vel.y = -Player.speed
	elseif control.down and not control.up then -- Going Down
		self.vel.y = Player.speed
	else
		self.vel.y = 0
	end

	self.rot = math.deg( -math.atan2( self.pos.y - love.mouse.getY(), love.mouse.getX() - self.pos.x ) )
	if self.rot < 0 then
		self.rot = self.rot + 360
	end
end

function Player:update( dt )
	self:checkInput()
	
	self.pos.x = self.pos.x + dt * self.vel.x
	self.pos.y = self.pos.y + dt * self.vel.y
end

function Player:draw( )
	Player.color[4] = 100
	love.graphics.setColor( unpack( Player.color ) )
	love.graphics.circle( "fill", self.pos.x, self.pos.y, Player.radius ) 
	
	Player.color[4] = 255
	love.graphics.setColor( unpack( Player.color ) )
	love.graphics.circle( "line", self.pos.x, self.pos.y, Player.radius ) 
end

function Player:getAABB( )
	return AABB:new( Vec2:new( self.pos.x - Player.radius, self.pos.y - Player.radius ), Vec2:new( Player.radius / 2, Player.radius / 2 ) )
end