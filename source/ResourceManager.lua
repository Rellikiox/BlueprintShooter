-- Resource Manager

ResourceManager = class( "ResourceManager" )

function ResourceManager:initialize( )
	self.images = { }
	self.sounds = { }
end

function ResourceManager:addSound( path, name )
	self.sounds[ name ] = love.sound.newSoundData( path )
end

function ResourceManager:getSound( name )
	return self.sound[ name ]
end

function ResourceManager:addImage( path, name )
	self.images[ name ] = love.graphics.newImage( path )
end

function ResourceManager:getImage( name )
	return self.images[ name ]
end

