-- TLbind v1.1, a simple system for creating professional control schemes
-- by Taehl (SelfMadeSpirit@gmail.com), with contributions by smrq

local b = { useKeyboard=true, useJoystick=true, deadzone=0.1 }	-- Defaults to keyboard and joystick enabled with deadzone of 0.1
local hold,tap,release = {}, {}, {}
hold.tap,hold.release = tap,release	-- Convenient shortcuts (example: if P1controls.tap.jump then P1.doJump(P1control.horiz) end)
-- The callbacks are .controlPressed and .controlReleased (they work just like Love's callbacks)

b.keys = {
    w="up", a="left", s="down", d="right", [" "]="jump", lctrl="attack", escape="exit",
    up="up", left="left", down="down", right="right", z="jump", rctrl="attack", 
	lshift = "throw", rshift = "throw", r="reload",
}          	-- .keys[KeyConstant] = "control"
b.joyAxes = {}       	-- .joyAxes[joystick#][axis#] = "control"
b.joyBtns = {}       	-- .joyBtns[joystick#][button#] = "control"
b.joyBalls = {}      	-- .joyBalls[joystick#][ball#] = {"x control", "y control"}
b.joyHats = {}       	-- .joyHats[joystick#][hat#] = {"l control", "r control", "u control", "d control"}
b.maps = {}          	-- .maps[analogue] = {"negative digital", "positive digital"}
b.circleAnalogue = {}	-- .circleAnalogue[entry#] = {"analogue 1", "analogue 2"}

-- Call this in love.update()
function b:update()
	-- Reset controls
	for k,v in pairs(hold) do if type(v)~="table" then hold[k] = false end end
	
	-- Check key inputs (if enabled)
	if b.useKeyboard and love.keyboard then for k,v in pairs(b.keys) do hold[v] = hold[v] or love.keyboard.isDown(k) end end
	
	-- Check joystick inputs (if enabled)
	if b.useJoystick and love.joystick then
		for j,binds in pairs(b.joyAxes) do for k,v in pairs(binds) do
			local x=love.joystick.getAxis(j,k)
			hold[v]=math.abs(x)<b.deadzone and 0 or x
		end end
		for j,binds in pairs(b.joyBtns) do for k,v in pairs(binds) do hold[v] = hold[v] or love.joystick.isDown(j,k) end end
		for j,binds in pairs(b.joyBalls) do for k,v in pairs(binds) do hold[v[1]], hold[v[2]] = love.joystick.getBall(j,k) end end
		for j,binds in pairs(b.joyHats) do for k,v in pairs(binds) do
			local z = love.joystick.getHat(j,k)
			if string.sub(z,1,1)=="l" then hold[v[1]]=true elseif string.sub(z,1,1)=="r" then hold[v[2]]=true end
			if string.sub(z,-1)=="u" then hold[v[3]]=true elseif string.sub(z,-1)=="d" then hold[v[4]]=true end
		end end
	end
	
	-- Impose digital controls onto analogue controls and vice versa (binding first if needed)
	for a,d in pairs(b.maps) do
		if not hold[a] then hold[a]=0 end
		if not hold[d[1]] then hold[d[1]]=false end
		if not hold[d[2]] then hold[d[2]]=false end
		if hold[d[1]] then hold[a]=-1 elseif hold[d[2]] then hold[a]=1 end
		if hold[a]<0 then hold[d[1]]=true elseif hold[a]>0 then hold[d[2]]=true end
	end
	
	-- Detect controls being tapped and released
	for k,v in pairs(hold) do
		if v then
			release[k] = false
			if tap[k]==false then tap[k]=true if hold.controlPressed then hold.controlPressed(k) end
			elseif tap[k]==true then tap[k]=nil
			end
		else
			tap[k] = false
			if release[k]==false then release[k]=true if hold.controlReleased then hold.controlReleased(k) end
			elseif release[k]==true then release[k]=nil
			end
		end
	end
	
	-- Constrain analogue pairs to a unit circle
	for k,v in ipairs(b.circleAnalogue) do
		local x,y = hold[v[1]], hold[v[2]]
		if x and y then
			local l = (x*x+y*y)^.5
			if l > 1 then hold[v[1]], hold[v[2]] = x/l, y/l end
		else	-- in case, for some strange reason, someone is constraining analogues which are both unbound and unmapped
			hold[v[1]], hold[v[2]] = 0, 0
		end
	end
end

return b, hold, tap, release