
WIDTH = 800
HEIGHT = 600
debug_on = false
function love.load()

	TLbind,control = love.filesystem.load("lib/TLbind.lua")()
	require( 'lib/TEsound' )
	require( 'lib/middleclass' )
	require( 'EntityManager' )
	require( 'ResourceManager' )
	require( 'entities/Player' )
	require( 'entities/Wall' )
	require( 'entities/FOV' )
	require( 'misc/Vec2' )
	require( 'misc/Clock' )
	
	local HC = require("lib/HardonCollider")
	Collider = HC(10, onCollision)
	
	love.graphics.setBackgroundColor(46,48,148)
	
	EM = EntityManager()
	RM = ResourceManager()
	
	RM:addImage( "textures/wall_pattern.png", "Wall_background_tile" )
	RM:addImage( "textures/grid_tile_w.png", "background_tile" )
	
	local grid_tile_img = RM:getImage( "background_tile" )
	local tile_width = grid_tile_img:getWidth()
	local tile_height = grid_tile_img:getHeight()
	local grid_tile = love.graphics.newQuad( 0, 0, tile_width, tile_height, tile_width, tile_height )
	
	local hor_tiles = math.ceil( WIDTH / tile_width )
	local ver_tiles = math.ceil( HEIGHT / tile_height )
	
	background_batch = love.graphics.newSpriteBatch( grid_tile_img, (hor_tiles + 1) * (ver_tiles + 1))
	for i = 1, hor_tiles, 1 do
		for j = 1, ver_tiles, 1 do
			background_batch:addq( grid_tile, (i - 1) * tile_width, (j - 1) * tile_height )
		end
	end
	
	player = EM:add( Player, 400, 301 )
	EM:add( Wall, 250, 100, 100, 50 )
	EM:add( Wall, 400, 100, 50, 50 )
	EM:add( Wall, 500, 400, 25, 25 )	
	EM:add( Wall, 500, 450, 25, 25 )	
	EM:add( Wall, 500, 350, 25, 25 )	
	EM:add( Wall, 500, 300, 25, 25 )	
	EM:add( Wall, 430, 300, 50, 100 )
end
	
function love.draw()

	-- background pattern
	love.graphics.setColor( 233, 247, 255, 25 )
	love.graphics.draw( background_batch )
	-- white rectangle
	love.graphics.setColor( 233, 247, 255, 64 )
	love.graphics.setLineWidth( 3 )
	love.graphics.rectangle( "line", 5, 5, WIDTH - 10, HEIGHT - 10 )
	love.graphics.setLineWidth( 1 )
	
	EM:draw()	
	
	if debug_on then
		love.graphics.print( love.timer.getFPS(), 5, 5 )
	end
end

function love.update(dt)
	TLbind:update()
	EM:update( dt )
	Collider:update(dt)
	TEsound.cleanup()
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	elseif key == "tab" then
		debug_on = not debug_on
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		player:addAction( "move", Vec2(x, y), { pos = Vec2(x, y) } )
	elseif button == "r" then
		player:addAction( "move", Vec2(x, y), { pos = Vec2(x, y), rot = { fixed = true, pos = Vec2(x, y) } } )
	elseif button == "m" then
		player:addAction( "move", Vec2(x, y), { pos = Vec2(x, y), rot = { fixed = true, pos = Vec2(300,400) } } )
	end
end

function love.mousereleased(x, y, button)
end

function onCollision(dt, obj1, obj2, dx, dy)
	obj1.parent:onCollision(obj2,  dx,  dy)
	obj2.parent:onCollision(obj1, -dx, -dy)
end
