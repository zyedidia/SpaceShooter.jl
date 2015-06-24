type Laser <: GameObject
	sprite::Sprite
	speed::Real
	angle::Real
	color::String
end

function Laser(texture_name, pos)
	sprite = Sprite()
	texture = manager.textures[texture_name]
	set_texture(sprite, texture)
	set_origin(sprite, Vector2f(get_size(texture).x / 2, get_size(texture).y / 2))
	set_position(sprite, pos)
	scale(sprite, Vector2f(X_SCALE, Y_SCALE))

	color = ""

	if Base.contains(texture_name, "Blue")
		color = "Blue"
	elseif Base.contains(texture_name, "Red")
		color = "Red"
	elseif Base.contains(texture_name, "Green")
		color = "Green"
	end

	Laser(sprite, LASER_SPEED, 0, color)
end

function update(laser::Laser, dt)
	update_pos(laser, dt)
end

function update_pos(laser::Laser, dt)
	pos = get_position(laser.sprite)
	size = get_size(get_texture(laser.sprite))
	if  pos.x > SCREEN_WIDTH + size.x / 2 || pos.x < 0 - size.x / 2 ||
		pos.y > SCREEN_HEIGHT + size.y / 2 || pos.y < 0 - size.y / 2
		die(laser)
	end

	velocity = Vector2f(laser.speed * cosd(laser.angle - 90) * dt * X_SCALE, laser.speed * sind(laser.angle - 90) * dt * Y_SCALE)
	set_rotation(laser.sprite, laser.angle)
	move(laser.sprite, velocity)
end

function draw(window, laser::Laser)
	draw(window, laser.sprite)

	color = laser.color == "Blue" ? SFML.blue : laser.color == "Red" ? SFML.red : SFML.green
	drawlight(window, get_position(laser.sprite), color, 25)
end
