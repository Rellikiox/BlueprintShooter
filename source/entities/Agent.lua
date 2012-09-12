-- Agent: an agent is any action-performing entity of the game, player or AI controlled

require( 'Queue' )

Agent = class( 'Agent' )

function Agent:initialize( x, y, color, radius )

	self.pos = Vec2:new( x, y )
	self.vel = Vec2:new( 0, 0 )
	self.rot = 0
	self.color = color
	self.radius = radius
	self.commander = Commander( self.pos )
	
	self.shape = Collider:addCircle( self.pos.x, self.pos.y, Player.radius )
	self.shape.parent = self
	Collider:addToGroup("agents", self.shape)
end

function Agent:move( dx, dy )
	self.pos.x = self.pos.x + dx
	self.pos.y = self.pos.y + dy
	self.shape:move( dx, dy )
end

function Agent:onCollision( other, dx, dy )
	self:move( dx, dy )
end

function Agent:update( dt )
	self:checkInput()
	local dx = dt * self.vel.x
	local dy = dt * self.vel.y
	self:move( dx, dy )
end

function Agent:draw( )
	self.color[4] = 100
	love.graphics.setColor( unpack( self.color ) )
	love.graphics.circle( "fill", self.pos.x, self.pos.y, self.radius ) 
	
	self.color[4] = 255
	love.graphics.setColor( unpack( self.color ) )
	love.graphics.circle( "line", self.pos.x, self.pos.y, self.radius ) 
	
	--[[ Draw the command list
	if not self.commands:empty( ) then
		love.graphics.line( self.pos.x, self.pos.y, self.commands.queue[ 1 ].pos.x, self.commands.queue[ 1 ].pos.y )
		for i = 2, #self.commands.queue do
			love.graphics.line( self.commands.queue[ i - 1 ].pos.x, self.commands.queue[ i - 1 ].pos.y, self.commands.queue[ i ].pos.x, self.commands.queue[ i ].pos.y )
		end
	end
	--]]
	
	self.commander:draw()
end

function Agent:addAction( x, y, a, e )
	self.commander:addAction( x, y, a, e )
end

function Agent:getAABB( )
	return AABB:new( Vec2:new( self.pos.x - Player.radius, self.pos.y - Player.radius ), Vec2:new( Player.radius / 2, Player.radius / 2 ) )
end

-- COMMANDER

Commander = class( 'Commander' )

function Commander:initialize( pos )
	self.commands = { }
	self.pos = pos
end

function Commander:currentAction( )
	if #self.commands == 0 then
		return nil
	end
	
	if self.commands[ 1 ]:endCondition() then
		table.remove( self.commands, 1 )
	end	
	
	return self.commands[ 1 ]
end

function Commander:addAction( x, y, action, end_cond, ... ) 
	table.insert( self.commands, Command( x, y, action, end_cond ) )
end

function Commander:draw( )
	if #self.commands ~= 0 then
		love.graphics.line( self.pos.x, self.pos.y, self.commands[ 1 ].pos.x, self.commands[ 1 ].pos.y )
		for i = 2, #self.commands do
			love.graphics.line( self.commands[ i - 1 ].pos.x, self.commands[ i - 1 ].pos.y, self.commands[ i ].pos.x, self.commands[ i ].pos.y )
		end
	end
end

-- COMMAND

Command = class( 'Command' )

function Command:initialize( x, y, action, endCond )
	self.pos = Vec2( x, y )
	self.action = action
	self.endCondition = endCond
end

function Command:endCondition( )
	return self:endCondition( )
end

function Command:execute( )
	self.action()
end