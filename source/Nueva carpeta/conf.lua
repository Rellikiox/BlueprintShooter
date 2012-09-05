function love.conf(t)
    t.modules.audio = false
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = false
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = false
    t.modules.timer = true
	t.title = "TLpath demonstration"
    t.author = "Taehl"
    t.version = 0.71
    t.console = false
	t.screen.vsynch = true
end
