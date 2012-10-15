-- Player

require( 'entities/FOV' )
require( 'entities/Agent' )

Player = class( "Player", Agent )

Player.radius = 10
Player.static.speed = 100
Player.static.color = { 255, 0, 0 }

function Player:initialize( x, y )
	Agent.initialize( self, x, y, Player.color, Player.radius )
	
	EM:add( FOV, self, 200, 120, Player.color )
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

	local rot = math.deg( -math.atan2( self.pos.y - love.mouse.getY(), love.mouse.getX() - self.pos.x ) )
	self:rotate( rot )
	--self.rot = rot 
end

