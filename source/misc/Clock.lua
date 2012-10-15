-- Clock

Clock = class( "Clock" )

function Clock:initialize( paused )
	self:restart( paused )
end

function Clock:restart( paused )
	self.birth = love.timer.getMicroTime()
	self.elapsed = 0
	if paused then
		self.paused = paused
	else
		self.paused = false
	end
end

function Clock:pause( )
	self.elapsed = self.elapsed + love.timer.getMicroTime() - self.birth
	self.paused = true
end

function Clock:unpause( )
	self.paused = false
	self.birth = love.timer.getMicroTime()
end

function Clock:getElapsedMicroseconds( )
	local time_elapsed = self.elapsed
	if not paused then
		time_elapsed = time_elapsed + (love.timer.getMicroTime() - self.birth)
	end
	return time_elapsed * 1000000
end

function Clock:getElapsedMiliseconds( )
	local time_elapsed = self.elapsed
	if not paused then
		time_elapsed = time_elapsed + (love.timer.getMicroTime() - self.birth)
	end
	return time_elapsed * 1000
end

function Clock:getElapsedSeconds( )
	local time_elapsed = self.elapsed
	if not paused then
		time_elapsed = time_elapsed + (love.timer.getMicroTime() - self.birth)
	end
	return time_elapsed
end