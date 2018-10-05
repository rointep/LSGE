----------------------------------
-- LSGE Parser script
--
----------------------------------


----------------------------------
-- Constants
----------------------------------
-- easing
Linear				= 0
EaseOut				= 1
EaseIn				= 2
QuadIn				= 3
QuadOut				= 4
QuadInOut			= 5
CubicIn				= 6
CubicOut			= 7
CubicInOut			= 8
QuartIn				= 9
QuartOut			= 10
QuartInOut			= 11
QuintIn				= 12
QuintOut			= 13
QuintInOut			= 14
SineIn				= 15
SineOut				= 16
SineInOut			= 17
ExpoIn				= 18
ExpoOut				= 19
ExpoInOut			= 20
CircIn				= 21
CircOut				= 22
CircInOut			= 23
ElasticIn			= 24
ElasticOut			= 25
ElasticHalfOut		= 26
ElasticQuarterOut	= 27
ElasticInOut		= 28
BackIn				= 29
BackOut				= 30
BackInOut			= 31
BounceIn			= 32
BounceOut			= 33
BounceInOut			= 34

-- layers
Background			= "Background"
Fail				= "Fail"
Pass				= "Pass"
Foreground			= "Foreground"

-- origin
TopLeft				= "TopLeft"
TopCenter			= "TopCentre"
TopRight			= "TopRight"
CenterLeft			= "CentreLeft"
Center				= "Centre"
CenterRight			= "CentreRight"
BottomLeft			= "BottomLeft"
BottomCenter		= "BottomCentre"
BottomRight			= "BottomRight"

-- blend modes
Blend				= "Blend"
Additive			= "Additive"

-- loop types (for animated sprites)
LoopForever			= "LoopForever"
LoopOnce 			= "LoopOnce"

-- screen anchor points
ScreenTopLeft 		= { x = 0	, 	y = 0	}
ScreenTopCenter		= { x = 0	, 	y = 240	}
ScreenTopRight		= { x = 0	, 	y = 480	}
ScreenCenterLeft	= { x = 320	, 	y = 0	}
ScreenCenter		= { x = 320	, 	y = 240	}
ScreenCenterRight	= { x = 320	, 	y = 480	}
ScreenBottomLeft	= { x = 640	, 	y = 0	}
ScreenBottomCenter	= { x = 640	, 	y = 240	}
ScreenBottomRight	= { x = 640	, 	y = 480	}



----------------------------------
-- Storyboard compiler
----------------------------------
local TIME = 0

function setTime(t)
	if not t or type(t) ~= "number" then error("You must provide a time value in milliseconds", 2) end
	TIME = math.floor(t)
end

function advanceTime(t)
	if not t then error("You must provide a time value in milliseconds", 2) end
	TIME = TIME + math.floor(t)
end

function getTime()
	return TIME
end

local function getTimeInternal(sprite)
	if sprite.loopRegionActive or sprite.triggerRegionActive then return 0 end
	return getTime()
end


local layers = { "Background", "Fail", "Pass", "Foreground" }
local layerMarkers = { Background = "//Storyboard Layer 0 (Background)", Fail = "//Storyboard Layer 1 (Fail)", Pass = "//Storyboard Layer 2 (Pass)", Foreground = "//Storyboard Layer 3 (Foreground)" }

function LSGE_BUILD_STORYBOARD()
	local lsge_content = {}
	local function write(f)
		table.insert(lsge_content, f)
	end

	write("[Events]")
	write("//Background and Video events")

	-- parse sprites
	for _, layer in ipairs(layers) do

		write(layerMarkers[layer])

		for k,v in ipairs(Sprite.__objects[layer]) do
			local H_FLIP 		= { s = false, t = nil }
			local V_FLIP 		= { s = false, t = nil }
			local BLMODE 		= { s = false, t = nil }
			local LCMDT			= nil
			local LCMDD			= nil

			local region 		= nil
			
			if #v.cmds >= 1 then
				if v.isAnimated then
					write("Animation," .. v.layer .."," .. v.origin .. ",\"" .. v.filepath .. "\"," .. v.sourceX .. "," .. v.sourceY .. "," .. v.frameCount .. "," .. v.frameDelay .. "," .. v.loopType)
				else
					write("Sprite," .. v.layer .."," .. v.origin .. ",\"" .. v.filepath .. "\"," .. v.sourceX .. "," .. v.sourceY)
				end
			end

			for _, cmd in ipairs(v.cmds) do
				if cmd[2] == "loop_begin" then
					write(" L" .. "," .. cmd[1] .. "," .. cmd[5])
					region = { cmd[1] }
				elseif cmd[2] == "trigger_begin" then
					write(" T" .. "," .. cmd[5] .. "," .. cmd[1] .. "," .. cmd[6] .. (cmd[7] and ","..cmd[7] or ""))
					region = { cmd[1] }
				elseif cmd[2] == "loop_end" or cmd[2] == "trigger_end" then
					region = nil
				end

				if cmd[2] == "fade" then
					write((region and " " or "") .. " F" .. "," .. cmd[4] .. "," .. cmd[1] .. "," .. (cmd[3] > 0 and cmd[1] + cmd[3] or "") .. "," .. cmd[5] .. (cmd[5] ~= cmd[6] and ","..cmd[6] or ""))
				end

				if cmd[2] == "move" then
					write((region and " " or "") .. " M" .. "," .. cmd[4] .. "," .. cmd[1] .. "," .. (cmd[3] > 0 and cmd[1] + cmd[3] or "") .. "," .. cmd[5] .. "," .. cmd[6] .. "," .. cmd[7] .. "," .. cmd[8])
				end	

				if cmd[2] == "moveX" then
					write((region and " " or "") .. " MX" .. "," .. cmd[4] .. "," .. cmd[1] .. "," .. (cmd[3] > 0 and cmd[1] + cmd[3] or "") .. "," .. cmd[5] .. (cmd[5] ~= cmd[6] and ","..cmd[6] or ""))
				end

				if cmd[2] == "moveY" then
					write((region and " " or "") .. " MY" .. "," .. cmd[4] .. "," .. cmd[1] .. "," .. (cmd[3] > 0 and cmd[1] + cmd[3] or "") .. "," .. cmd[5] .. (cmd[5] ~= cmd[6] and ","..cmd[6] or ""))
				end

				if cmd[2] == "scale" then
					write((region and " " or "") .. " S" .. "," .. cmd[4] .. "," .. cmd[1] .. "," .. (cmd[3] > 0 and cmd[1] + cmd[3] or "") .. "," .. cmd[5] .. (cmd[5] ~= cmd[6] and ","..cmd[6] or ""))
				end

				if cmd[2] == "vecScale" then
					write((region and " " or "") .. " V" .. "," .. cmd[4] .. "," .. cmd[1] .. "," .. (cmd[3] > 0 and cmd[1] + cmd[3] or "") .. "," .. cmd[5] .. "," .. cmd[6] .. "," .. cmd[7] .. "," .. cmd[8])
				end

				if cmd[2] == "rotate" then
					write((region and " " or "") .. " R" .. "," .. cmd[4] .. "," .. cmd[1] .. "," .. (cmd[3] > 0 and cmd[1] + cmd[3] or "") .. "," .. cmd[5] .. (cmd[5] ~= cmd[6] and ","..cmd[6] or ""))
				end

				if cmd[2] == "color" then
					write((region and " " or "") .. " C" .. "," .. cmd[4] .. "," .. cmd[1] .. "," .. (cmd[3] > 0 and cmd[1] + cmd[3] or "") .. "," .. cmd[5] .. "," .. cmd[6] .. "," .. cmd[7] .. "," .. cmd[8] .. "," .. cmd[9] .. "," .. cmd[10])
				end

				if cmd[2] == "hflip" then
					if H_FLIP.s and cmd[4] == false then
						write((region and " " or "") .. " P" .. ",0," .. H_FLIP.t .. "," .. cmd[1] .. ",H")
						H_FLIP = { s = false, t = nil }
					else
						H_FLIP = { s = true, t = cmd[1] }
					end
				end

				if cmd[2] == "vflip" then
					if V_FLIP.s and cmd[4] == false then
						write((region and " " or "") .. " P" .. ",0," .. V_FLIP.t .. "," .. cmd[1] .. ",V")
						V_FLIP = { s = false, t = nil }
					else
						V_FLIP = { s = true, t = cmd[1] }
					end
				end

				if cmd[2] == "blendmode" then
					if BLMODE.s and cmd[4] == Blend then
						write((region and " " or "") .. " P" .. ",0," .. BLMODE.t .. "," .. cmd[1] .. ",A")
						BLMODE = { s = false, t = nil }
					else
						BLMODE = { s = true, t = cmd[1] }
					end
				end

				LCMDT = cmd[1]
				LCMDD = cmd[3]
			end

			if H_FLIP.s then
				write(" P" .. ",0," .. H_FLIP.t .. "," .. LCMDT + LCMDD .. ",H")
			end
			if V_FLIP.s then
				write(" P" .. ",0," .. V_FLIP.t .. "," .. LCMDT + LCMDD .. ",H")
			end
			if BLMODE.s then
				write(" P" .. ",0," .. BLMODE.t .. "," .. LCMDT + LCMDD .. ",A")
			end
		end
	end

 	-- parse sounds (TODO)
 	write("//Storyboard Sound Samples")


 	-- write out the complete storyboard
 	local sb_filename = LSGE_DESTINATION_FILEPATH or "output.osb"
 	local filehandle, msg = io.open(sb_filename, "w+")
 	if not filehandle then error("Unable to write storyboard file -> " .. msg) end

 	for i, line in ipairs(lsge_content) do
 		filehandle:write(line)
 		filehandle:write("\n")
 	end

 	filehandle:close()

 	return true
end



----------------------------------
-- Sprite class
----------------------------------
Sprite = {}
Sprite.__objects = {
	["Background"] 	= {},
	["Fail"] 		= {},
	["Pass"] 		= {},
	["Foreground"] 	= {},
}

function Sprite:create(filepath, layer, origin, x, y) --Sprite (filepath, layer, origin, [x = 0, y = 0])
	require_arguments(1, filepath)
	validate_arguments("Sprite", "filepath", filepath, "layer", layer, "origin", origin, "number", x, "number", y)

	local o = {
		filepath = filepath,
		layer = layer or Background,
		origin = origin or TopLeft,
		sourceX = x and round(x) or 0,
		sourceY = y and round(y) or 0,
		alpha = 1,
		sc_scale = 1,
		vec_scale = { x = 1, y = 1},
		rotation = 0,
		color_rgb = { r = 255, g = 255, b = 255 },
		hflip = false,
		vflip = false,
		blendMode = Blend,

		loopRegionActive = false,
		triggerRegionActive = false,

		localTime = 0,
		regionTime = nil,

		cmds = {},
	}

	o.x = o.sourceX
	o.y = o.sourceY

	table.insert(Sprite.__objects[o.layer], o)
	setmetatable(o, { __index = Sprite })

	return o
end
setmetatable(Sprite, { __call = Sprite.create })


-- utility
function Sprite:clone()
	if not instanceof(self, Sprite) then classUsageError() end	
	return deepcopy(self)
end

function Sprite:destroy()
	if not instanceof(self, Sprite) then classUsageError() end	
	if self then return removevalue(Sprite.__objects[self.layer], self) end
	return false
end

function Sprite:setFilepath(filepath)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, filepath)
	validate_arguments("Sprite:setFilepath", "filepath", filepath)
	self.filepath = filepath
	return self
end

function Sprite:setLayer(layer)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, layer)
	validate_arguments("Sprite:setLayer", "layer", layer)
	removevalue(Sprite.__objects[self.layer], self)
	table.insert(Sprite.__objects[layer], self)
	self.layer = layer
	return self
end

function Sprite:setOrigin(origin)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, origin)
	validate_arguments("Sprite:setOrigin", "origin", origin)
	self.origin = origin
	return self
end

function Sprite:clearCommands()
	if not instanceof(self, Sprite) then classUsageError() end	
	self.cmds = {}
	return self
end


-- delay
function Sprite:delay(t)
	if not instanceof(self, Sprite) then classUsageError() end	
	if self.loopRegionActive or self.triggerRegionActive then
		self.regionTime = self.regionTime + math.floor(t)
	else
		self.localTime = self.localTime + math.floor(t)
	end
	return self
end

function Sprite:setDelayTime(t)
	if not instanceof(self, Sprite) then classUsageError() end	
	if not t or type(t) ~= "number" then error("You must provide a time value in milliseconds") end
	if self.loopRegionActive or self.triggerRegionActive then
		self.regionTime = math.floor(t)
	else
		self.localTime = math.floor(t)
	end
	return self
end

-- accessors
function Sprite:getDelayTime()
	if not instanceof(self, Sprite) then classUsageError() end	
	if self.loopRegionActive or self.triggerRegionActive then
		return self.regionTime
	end
	return self.localTime
end

function Sprite:getX()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.x
end

function Sprite:getY()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.y
end

function Sprite:getAlpha()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.alpha
end

function Sprite:getScale()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.sc_scale
end

function Sprite:getVectorScale()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.vec_scale
end

function Sprite:getRotation()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.rotation
end

function Sprite:isFlippedHorizontally()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.hflip
end

function Sprite:isFlippedVertically()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.vflip
end

function Sprite:getBlendMode()
	if not instanceof(self, Sprite) then classUsageError() end
	return self.blendMode
end

function Sprite:getColor()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.color_rgb
end

function Sprite:getFilepath()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.filepath
end

function Sprite:getLayer()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.layer
end

function Sprite:getOrigin()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self.origin
end


-- quick visibility toggles
function Sprite:show()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self:fade(0, 1, 0, Linear)
end

function Sprite:hide()
	if not instanceof(self, Sprite) then classUsageError() end	
	return self:fade(1, 0, 0, Linear)
end


-- fade
function Sprite:fade(startalpha, endalpha, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end
	require_arguments(2, startalpha, endalpha)
	validate_arguments("Sprite:fade", "number", startalpha, "number", endalpha, "number", duration, "easing", easing)
	local duration = duration and round(duration) or 0
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "fade", duration, easing or Linear, duration == 0 and endalpha or startalpha, endalpha })
	self.alpha = endalpha
	return self
end

function Sprite:fadeTo(endalpha, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end
	require_arguments(1, endalpha)
	validate_arguments("Sprite:fadeTo", "number", startalpha, "number", endalpha, "number", duration, "easing", easing)
	return self:fade(self:getAlpha(), endalpha, duration, easing)
end


-- move
function Sprite:move(sx, sy, tx, ty, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(4, sx, sy, tx, ty)
	validate_arguments("Sprite:move", "number", sx, "number", sy, "number", tx, "number", ty, "number",  duration, "easing", easing)
	local duration = duration and round(duration) or 0
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "move", duration, easing or Linear, duration == 0 and round(tx) or round(sx), duration == 0 and round(ty) or round(sy), round(tx), round(ty) })
	self.x, self.y = round(tx), round(ty)
	return self
end

function Sprite:moveTo(tx, ty, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(2, tx, ty)
	validate_arguments("Sprite:moveTo", "number", tx, "number", ty, "number", duration, "easing", easing)
	return self:move(self:getX(), self:getY(), tx, ty, duration, easing)
end

function Sprite:moveX(sx, tx, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(2, sx, tx)
	validate_arguments("Sprite:moveX", "number", sx, "number", tx, "number", duration, "easing", easing)
	local duration = duration and round(duration) or 0
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "moveX", duration, easing or Linear, duration == 0 and round(tx) or round(sx), round(tx) })
	self.x = round(tx)
	return self
end

function Sprite:moveToX(tx, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, tx)
	validate_arguments("Sprite:moveToX", "number", tx, "number", duration, "easing", easing)
	return self:moveX(self:getX(), tx, duration, easing)
end

function Sprite:moveY(sy, ty, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(2, sy, ty)
	validate_arguments("Sprite:moveY", "number", sy, "number", ty, "number", duration, "easing", easing)
	local duration = duration and round(duration) or 0
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "moveY", duration, easing or Linear, duration == 0 and round(ty) or round(sy), round(ty) })
	self.y = round(ty)
	return self
end

function Sprite:moveToY(ty, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, ty)
	validate_arguments("Sprite:moveToY", "number", ty, "number", duration, "easing", easing)
	return self:moveY(self:getY(), ty, duration, easing)
end


-- scale
function Sprite:scale(startscale, endscale, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end
	require_arguments(2, startscale, endscale)
	validate_arguments("Sprite:scale", "number", startscale, "number", endscale, "number", duration, "easing", easing)
	local duration = duration and round(duration) or 0
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "scale", duration, easing or Linear, duration == 0 and endscale or startscale, endscale })
	self.sc_scale = endscale
	return self
end

function Sprite:scaleTo(endscale, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end
	require_arguments(1, endscale)
	validate_arguments("Sprite:scale", "number", endscale, "number", duration, "easing", easing)
	return self:scale(self:getScale(), endscale, duration, easing)
end

function Sprite:vecScale(startscale_x, startscale_y, endscale_x, endscale_y, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end
	require_arguments(4, startscale_x, startscale_y, endscale_x, endscale_y)
	validate_arguments("Sprite:vecScale", "number", startscale_x, "number", startscale_y, "number", endscale_x, "number", endscale_y, "number", duration, "easing", easing)
	local duration = duration and round(duration) or 0

	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "vecScale", duration, easing or Linear, duration == 0 and endscale_x or startscale_x, duration == 0 and endscale_y or startscale_y, endscale_x, endscale_y })
	self.vec_scale = { x = endscale_x, y = endscale_y }
	return self
end

function Sprite:vecScaleTo(endscale_x, endscale_y, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end
	require_arguments(2, endscale_x, endscale_y)
	validate_arguments("Sprite:vecScaleTo", "number", endscale_x, "number", endscale_y, "number", duration, "easing", easing)
	return self:vecScale(self:getVectorScale().x, self:getVectorScale().y, endscale_x, endscale_y, duration, easing)
end


-- rotate
function Sprite:rotate(fromradians, toradians, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(2, fromradians, toradians)
	validate_arguments("Sprite:rotate", "number", fromradians, "number", toradians, "number", duration, "easing", easing)
	local duration = duration and round(duration) or 0
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "rotate", duration, easing or Linear, duration == 0 and toradians or fromradians, toradians })
	self.rotation = rotation
	return self
end

function Sprite:rotateTo(toradians, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, toradians)
	validate_arguments("Sprite:rotate", "number", toradians, "number", duration, "easing", easing)
	return self:rotate(self:getRotation(), toradians, duration, easing)
end


-- color
function Sprite:color(sr, sg, sb, tr, tg, tb, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(6, sr, sg, sb, tr, tg, tb)
	validate_arguments("Sprite:color", "number", sr, "number", sg, "number", sb, "number", tr, "number", tg, "number", tb, "number",  duration, "easing", easing)
	local duration = duration and round(duration) or 0
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "color", duration, easing or Linear, duration == 0 and round(tr) or round(sr), duration == 0 and round(tg) or round(sg), duration == 0 and round(tb) or round(sb), round(tr), round(tg), round(tb) })
	self.color_rgb = { r = round(tr), g = round(tg), b = round(tb) }
	return self
end

function Sprite:colorTo(tr, tg, tb, duration, easing)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(3, tr, tg, tb)
	validate_arguments("Sprite:colorTo", "number", tr, "number", tg, "number", tb, "number",  duration, "easing", easing)
	return self:color(self:getColor().r, self:getColor().g, self:getColor().b, tr, tg, tb, duration, easing)
end


-- parameters
function Sprite:setHorizontalFlip(flipped)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, flipped)
	validate_arguments("Sprite:setHorizontalFlip", "boolean", flipped)
	if self.hflip ~= flipped then
		table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "hflip", 0, Linear, flipped })
		self.hflip = flipped
	end
	return self
end

function Sprite:setVerticalFlip(flipped)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, flipped)
	validate_arguments("Sprite:setVerticalFlip", "boolean", flipped)
	if self.vflip ~= flipped then
		table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "vflip", 0, Linear, flipped })
		self.vflip = flipped
	end
	return self
end

function Sprite:setBlendMode(mode)
	if not instanceof(self, Sprite) then classUsageError() end
	require_arguments(1, mode)
	validate_arguments("Sprite:setBlendMode", "blendmode", mode)
	if self.blendMode ~= flipped then
		table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "blendmode", 0, Linear, mode })
		self.blendMode = mode
	end
	return self
end


-- loop
function Sprite:beginLoopRegion(n)
	if not instanceof(self, Sprite) then classUsageError() end	
	require_arguments(1, n)
	validate_arguments("Sprite:beginLoopRegion", "number", n)
	if self.loopRegionActive then error("End the currently open loop region before starting a new one", 2) end
	if self.triggerRegionActive then error("End the currently open event region before starting a loop region", 2) end
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "loop_begin", 0, Linear, round(n) })
	self.loopRegionActive = true
	self.regionTime = 0
	return self
end

function Sprite:endLoopRegion()
	if not instanceof(self, Sprite) then classUsageError() end
	if not self.loopRegionActive then error("Loop region not started", 2) end
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "loop_end", 0, Linear })
	self.loopRegionActive = false
	self.regionTime = nil
	return self
end

function Sprite:beginEventRegion(event, starttime, endtime, group)
	if not instanceof(self, Sprite) then classUsageError() end
	require_arguments(3, event, starttime, endtime)
	validate_arguments("Sprite:beginEventRegion", "string", event, "number", starttime, "number", endtime, "number", group)
	if self.loopRegionActive then error("End the currently open loop region before starting an event region", 2) end
	if self.triggerRegionActive then error("End the currently open event region before starting a new one", 2) end
	table.insert(self.cmds, { round(starttime), "trigger_begin", 0, Linear, event, round(endtime), group })
	self.triggerRegionActive = true
	self.regionTime = 0
	return self
end

function Sprite:endEventRegion()
	if not instanceof(self, Sprite) then classUsageError() end
	if not self.triggerRegionActive then error("Event region not started", 2) end
	table.insert(self.cmds, { round(getTimeInternal(self) + self:getDelayTime()), "trigger_end", 0, Linear })
	self.triggerRegionActive = false
	self.regionTime = nil
	return self
end



----------------------------------
-- AnimatedSprite class
----------------------------------
-- this class inherits methods from Sprite class
AnimatedSprite = {}

function AnimatedSprite:create(filepath, layer, origin, x, y, frameCount, frameDelay, loopType) --AnimatedSprite (filepath, layer, origin, [x = 0, y = 0, frameCount = 1, frameDelay = 50, loopType = LoopForever])
	require_arguments(1, filepath)
	validate_arguments("AnimatedSprite", "filepath", filepath, "layer", layer, "origin", origin, "number", x, "number", y, "number", frameCount, "number", frameDelay, "looptype", loopType)

	local o = Sprite(filepath, layer, origin, x, y)
	o.isAnimated = true
	o.frameCount = frameCount or 1
	o.frameDelay = frameDelay and round(frameDelay) or 50
	o.loopType = loopType or LoopForever

	setmetatable(o, { __index = AnimatedSprite })

	return o
end
setmetatable(AnimatedSprite, { __call = AnimatedSprite.create, __index = Sprite })


function AnimatedSprite:setFrameCount(n)
	require_arguments(1, n)
	validate_arguments("AnimatedSprite:setFrameCount", "number", n)
	self.frameCount = n
	return self
end
function AnimatedSprite:getFrameCount()
	return self.frameCount
end

function AnimatedSprite:setFrameDelay(delay)
	require_arguments(1, delay)
	validate_arguments("AnimatedSprite:setFrameDelay", "number", delay)
	self.frameDelay = delay
	return self
end
function AnimatedSprite:getFrameDelay()
	return self.frameDelay
end

function AnimatedSprite:setLoopType(loopType)
	require_arguments(1, loopType)
	validate_arguments("AnimatedSprite:setLoopType", "looptype", looptype)
	self.loopType = loopType
	return self
end
function AnimatedSprite:getLoopType()
	return self.loopType
end



----------------------------------
-- Utility code
----------------------------------
function require_arguments(n, ... )
	if n ~= #{ ... } then
		error("Function requires at least " .. n .. " arguments", 3)
	end
	return true
end

function validate_arguments(ot, ... )
	local args = { ... }
	for i = 1, #args, 2 do
		if args[i+1] ~= nil then
			if args[i] == "filepath" then
				if args[i+1] ~= nil and type(args[i+1]) ~= "string" then error("You must provide a valid filepath parameter for " .. ot .. "()", 3) end
			elseif args[i] == "layer" then
				if args[i+1] ~= nil and not verify_enum(args[i], args[i+1]) then error("You must provide a valid 'Layer' parameter for " .. ot .. "()", 3) end
			elseif args[i] == "origin" then
				if args[i+1] ~= nil and not verify_enum(args[i], args[i+1]) then error("You must provide a valid 'Origin' parameter for " .. ot .. "()", 3) end
			elseif args[i] == "easing" then
				if args[i+1] ~= nil and not verify_enum(args[i], args[i+1]) then error("You must provide a valid 'Easing' parameter for " .. ot .. "()", 3) end
			elseif args[i] == "blendmode" then
				if args[i+1] ~= nil and not verify_enum(args[i], args[i+1]) then error("You must provide a valid 'BlendMode' parameter for " .. ot .. "()", 3) end
			elseif args[i] == "looptype" then
				if args[i+1] ~= nil and not verify_enum(args[i], args[i+1]) then error("You must provide a valid 'LoopType' parameter for " .. ot .. "()", 3) end
			elseif args[i] == "number" then
				if args[i+1] ~= nil and type(args[i+1]) ~= "number" then error("You must provide a valid number parameter for " .. ot .. "()", 3) end
			elseif args[i] == "string" then
				if args[i+1] ~= nil and type(args[i+1]) ~= "string" then error("You must provide a valid string parameter for " .. ot .. "()", 3) end
			elseif args[i] == "boolean" then
				if args[i+1] ~= nil and type(args[i+1]) ~= "boolean" then error("You must provide a valid boolean parameter for " .. ot .. "()", 3) end
			end
		end
	end
	return true
end

function verify_enum(enum, value)
	if not value or type(value) == "boolean" then return false end

	if enum == "layer" then
		return (value == Background or value == Fail or value == Pass or value == Foreground)
	elseif enum == "origin" then
		return (value == TopLeft or value == TopCenter or value == TopRight or value == CenterLeft or value == Center or value == CenterRight or value == BottomLeft or value == BottomCenter or value == BottomRight)
	elseif enum == "easing" then
		return (tonumber(value) and value >= 0 and value <= 34)
	elseif enum == "blendmode" then
		return (value == Blend or value == Additive)
	elseif enum == "looptype" then
		return (value == LoopForever or value == LoopOnce)
	end
	return false
end

function classUsageError()
	error("Syntax error - use the colon operator to call class methods", 3)
end

function instanceof(object, class)
	local mt = getmetatable(object)
	while mt and mt.__index do
		if mt.__index == class then return true end
		mt = getmetatable(mt.__index)
	end
	return false
end

function removevalue(t, value)
	for k,v in pairs(t) do
		if v == value then
			table.remove(t, k)
			return true
		end
	end
	return false
end

function deepcopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function round(val)
	return math.floor(val + 0.5)
end