
WIDTH = 800
HEIGHT = 600

function love.load()
	
	TLbind,control = love.filesystem.load("lib/TLbind.lua")()

	require( 'lib/middleclass' )
	require( 'EntityManager' )
	require( 'entities/Player' )
	require( 'entities/Obstacle' )
	require( 'entities/FOV' )
	require( 'Vec2' )
	
	love.graphics.setBackgroundColor(46,48,148)
	
	local grid_tile_img = love.graphics.newImage( "textures/grid_tile_w.png" )
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
	
	EM = EntityManager:new()
	--[[
	EM:add( Obstacle, 100, 100, 25, 25 )
	EM:add( Obstacle, 400, 200, 25, 25 )
	EM:add( Obstacle, 200, 200, 25, 25 )
	EM:add( Obstacle, 400, 500, 25, 25 )
	EM:add( Obstacle, 100, 350, 25, 25 )
	EM:add( Obstacle, 200, 350, 25, 25 )--]]
	EM:add( Obstacle, 300, 350, 25, 25 )
	EM:add( Obstacle, 400, 350, 25, 25 )
	
	--EM:add( FOV, pseudo_player, 100, 135, { 0, 255, 255 } )
	EM:add( Player, 400, 300 )
	
end
	
function love.draw()
	-- background pattern
	love.graphics.setColor( 233, 247, 255, 25 )
	love.graphics.draw( background_batch )
	-- white rectangle
	love.graphics.setColor( 233, 247, 255, 64 )
	love.graphics.rectangle( "fill", 5, 		5, 			WIDTH - 10, 3 )				-- top
	love.graphics.rectangle( "fill", 5, 		HEIGHT - 7, WIDTH - 10, 3 ) 			-- bottom
	love.graphics.rectangle( "fill", 5, 		8, 			3, 			HEIGHT - 15 )	-- left
	love.graphics.rectangle( "fill", WIDTH - 8, 8, 			3, 			HEIGHT - 15 ) 	-- right
	
	EM:draw()
	--[[
	mouse_pos = { x = love.mouse.getX(), y = love.mouse.getY() }
	point_list = caja1:pointsFacing( mouse_pos )
	for i = 1, #point_list - 1 do
		love.graphics.line( point_list[i].x, point_list[i].y, point_list[i+1].x, point_list[i+1].y )
	end
	--]]
	
end

function love.update(dt)
	TLbind:update()
	EM:update( dt )
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end
