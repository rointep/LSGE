-- Caution: this script will generate a huge storyboard (around 2 million lines)
songLength = 400000
spawnRate = 1

setTime(0)

while getTime() < songLength do
	local image = Sprite("test.png", Background, Centre, 0, 0)
	image:scaleTo(0.02 + math.random() * 0.08)

	local a = math.random() * 360
	local distance = 100 + math.random() * 200
	local time = 2000 + math.random() * 2000
	local tx = 320 + math.sin(math.rad(a)) * distance
	local ty = 240 + math.cos(math.rad(a)) * distance

	image:move(320, 240, tx, ty, time, QuadInOut)
	image:fadeTo(1, time * 0.1):delay(time * 0.5)
	image:fadeTo(0, time * 0.4)

	advanceTime(spawnRate)
end