-- Agent: an agent is any action-performing entity of the game, player or AI controlled

require( 'Queue' )

Agent = class( 'Agent' )

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
	self:checkInput()
	local dx = dt * self.vel.x
	local dy = dt * self.vel.y
	local dr = dt * self.vel.r
	
	print( self.rot .. " " .. self.vel.r .. " " .. dr )
	self:move( dx, dy, dr )	
end

function Agent:draw( )
	self.color[4] = 100
	love.graphics.setColor( unpack( self.color ) )
	love.graphics.circle( "fill", self.pos.x, self.pos.y, self.radius ) 
	
	self.color[4] = 255
	love.graphics.setColor( unpack( self.color ) )
	love.graphics.circle( "line", self.pos.x, self.pos.y, self.radius ) 
	
	--self.commander:draw()
end

function Agent:addAction( x, y, a )
	self.commander:addAction( x, y, a )
end

function Agent:getAABB( )
	return AABB:new( Vec2:new( self.pos.x - Player.radius, self.pos.y - Player.radius ), Vec2:new( Player.radius / 2, Player.radius / 2 ) )
end

-- Agent Actions

function Agent:wait( t )
	
end

function Agent:travelTowards( p )

end

function Agent:rotate( r )
	if math.abs( self.rot - r ) > 1 then
		local rot_dif = r - self.rot
		if rot_dif > 180 then
			self.vel.r = -180
			--rot_dif = rot_dif - 360
		else
			self.vel.r = 180
		end
		--self.vel.r = rot_dif
	else
		self.vel.r = 0
	end
end

-- COMMANDER

Commander = class( 'Commander' )

function Commander:initialize( pos )
	self.commands = { }
	self.pos = pos
	--self.finished = false
end

function Commander:currentAction( )
	--[[
	if #self.commands == 0 then
		return nil
	end
	if self.finished then
		table.remove( self.commands, 1 )
		self.finished = false
	end	
	--]]
	return self.commands[ 1 ]
end

function Commander:finishCurrentAction( )
	--self.finished = true
	if #self.commands > 0 then
		table.remove( self.commands, 1 )
	end
end

function Commander:addAction( x, y, action, end_cond, ... ) 
	table.insert( self.commands, Command( x, y, action ) )
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