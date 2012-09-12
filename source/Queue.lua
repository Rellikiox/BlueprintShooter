-- Queue

Queue = class( 'Queue' )

function Queue:initialize( )
	self.queue = { }
end

function Queue:push( element )
	table.insert( self.queue, element )
end

function Queue:pop( )
	if #self.queue ~= 0 then
		local element = self.queue[ 1 ]
		table.remove( self.element, 1 )
		return element
	else
		return nil
	end
end

function Queue:head( )
	if #self.queue ~= 0 then
		return self.queue[ 1 ]
	else
		return nil
	end
end

function Queue:tail( )
	if #self.queue ~= 0 then
		return self.queue[ #self.queue ]
	else
		return nil
	end
end

function Queue:size( )
	return #self.queue
end

function Queue:empty( )
	return #self.queue == 0
end