-- Agent: an agent is any action-performing entity of the game, player or AI controlled

require( 'misc/Queue' )

Agent = class( 'Agent' )

Agent.static.MAX_ROTATION_SPEED = 1800
Agent.static.MAX_MOVEMENT_SPEED = 100

function Agent:initialize( x, y, color, radius )

	self.pos = Vec2:new( x, y )
	self.vel = Vec2:new( 0, 0 )
	self.vel.r = 0
	self.rot = 0
	self.color = color
	self.radius = radius
	
	self.commander = Commander( self.pos )	
	
	self.shape = Collider:addCircle( self.pos.x, self.pos.y, Player.radius )
	self.shape.parent = self
	Collider:addToGroup("agents", self.shape)
end

function Agent:move( dx, dy, dr )
	self.pos.x = self.pos.x + dx
	self.pos.y = self.pos.y + dy
	
	self.rot   = self.rot + dr
	
	self.shape:move( dx, dy )
	self.shape:rotate( math.rad( dr ) )
end

function Agent:onCollision( other, dx, dy )
	self:move( dx, dy, 0 )
end

function Agent:update( dt )
	--self:checkInput()
	if not self.commander:isEmpty() then
		local action = self.commander:currentAction()
		if action.name == "move" then
			self:moveTo( action.args )
		end

		local dx = dt * self.vel.x * Agent.MAX_MOVEMENT_SPEED
		local dy = dt * self.vel.y * Agent.MAX_MOVEMENT_SPEED
		local dr = dt * self.vel.r * Agent.MAX_ROTATION_SPEED
		self:move( dx, dy, dr )	
	end
end

function Agent:draw( )
	self.color[4] = 100
	love.graphics.setColor( unpack( self.color ) )
	love.graphics.circle( "fill", self.pos.x, self.pos.y, self.radius ) 
	
	self.color[4] = 255
	love.graphics.setColor( unpack( self.color ) )
	love.graphics.circle( "line", self.pos.x, self.pos.y, self.radius ) 
	
	self.commander:draw()
end

function Agent:addAction( name, pos, extra )
	self.commander:addAction( name, pos, extra )
end

function Agent:getAABB( )
	return AABB:new( Vec2:new( self.pos.x - Player.radius, self.pos.y - Player.radius ), Vec2:new( Player.radius / 2, Player.radius / 2 ) )
end

-- Turns r degrees
function Agent:turn( rot )
	local rot_left = rot - self.rot
	if math.abs( rot_left ) > 0.5 then
		if rot_left < -180 then
			self.vel.r = rot_left + 360
		elseif rot > 180 then
			self.vel.r = rot_left - 360
		else
			self.vel.r = rot_left
		end
		self.vel.r = self.vel.r / 180
	end
end

-- Agent Actions

function Agent:wait( t )
	
end

function Agent:moveTo( args )
	local dir = args.pos - self.pos
	if dir:Length() >= 1 then
		dir:Normalize()
		self.vel.x = dir.x
		self.vel.y = dir.y
	else
		self.commander:finishCurrentAction()
	end
	
	if args.rot then
		if args.rot.fixed then
			local rot = math.deg( -math.atan2( self.pos.y - args.rot.pos.y, args.rot.pos.x - self.pos.x ) )
			self:turn( rot )
		else
			local rot = math.deg( -math.atan2( self.pos.y - args.rot.pos.y, args.rot.pos.x - self.pos.x ) )
			self:turn( rot )
		end
	end
end

function Agent:rotate( args )
	local rot_left = r - self.rot
	if math.abs( rot_left ) > 0.5 then
		self:turn( rot_left )
	else
		self.commander:finishCurrentAction()
	end
end

-- COMMANDER

Commander = class( 'Commander' )

function Commander:initialize( pos )
	self.commands = { }
	self.pos = pos
end

function Commander:currentAction( )
	return self.commands[ 1 ]
end

function Commander:finishCurrentAction( )
	if #self.commands > 0 then
		table.remove( self.commands, 1 )
	end
end

function Commander:addAction( name, pos, extra ) 
	table.insert( self.commands, Command(name, pos, extra) )
end

function Commander:isEmpty( )
	return #self.commands == 0
end

function Commander:draw( )
	if #self.commands ~= 0 then
		love.graphics.line( self.pos.x, self.pos.y, self.commands[ 1 ].pos.x, self.commands[ 1 ].pos.y )
		self.commands[ 1 ]:draw()
		for i = 2, #self.commands do
			love.graphics.line( self.commands[ i - 1 ].pos.x, self.commands[ i - 1 ].pos.y, self.commands[ i ].pos.x, self.commands[ i ].pos.y )
			self.commands[ i ]:draw()
		end
	end
end

-- COMMAND

Command = class( 'Command' )

function Command:initialize( name, pos, extra )
	self.name = name
	self.pos = pos
	self.args = extra
end

function Command:modify( name, pos, ... )
	self.name = name
	self.pos = pos
	self.args = arg
end

function Command:draw( )
	
	love.graphics.circle( "line", self.pos.x, self.pos.y, 5 )
	local r, g, b, a = love.graphics.getColor( )
	love.graphics.setColor( r, g, b, 100 )
	love.graphics.circle( "fill", self.pos.x, self.pos.y, 5 )
	
end