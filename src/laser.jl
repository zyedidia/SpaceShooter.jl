type Laser
	sprite::Sprite
	speed::Real
	angle::Real
	color::Color
end

function Laser(texture_name, pos)
	sprite = Sprite()
	texture = manager.textures[texture_name]
	set_texture(sprite, texture)
	set_origin(sprite, Vector2f(get_size(texture).x / 2, get_size(texture).y / 2))
	set_position(sprite, pos)
	scale(sprite, Vector2f(X_SCALE, Y_SCALE))

	color = SFML.black

	if Base.contains(texture_name, "Blue")
		color = SFML.blue
	elseif Base.contains(texture_name, "Red")
		color = SFML.red
	elseif Base.contains(texture_name, "Green")
		color = SFML.green
	end

	Laser(sprite, LASER_SPEED, 0, color)
end

function update(laser::Laser, dt)
	update_pos(laser, dt)
	check_collision(laser)
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

function check_collision(laser::Laser)
	laser_bounds = get_globalbounds(laser.sprite)
	for obj in game_objects::Array{GameObject}
		obj_bounds = get_globalbounds(obj.sprite)
		if intersects(obj_bounds, laser_bounds)
			laser_collision(obj, laser)
		end
	end
end

function die(laser::Laser)
	index = find(lasers::Array{Laser} .== laser)[1]
	splice!(lasers::Array{Laser}, index)
end

function draw(window, laser::Laser)
	draw(window, laser.sprite)

	lightshader = manager.shaders["lightshader"]
	set_parameter(lightshader, "frag_LightOrigin", get_position(laser.sprite))
	set_parameter(lightshader, "frag_LightColor", Vector3f(laser.color.r, laser.color.g, laser.color.b))
	set_parameter(lightshader, "frag_LightAttenuation", 25)
	states = RenderStates(SFML.blend_add, lightshader)

	draw(window, render_texture_sprite, states)
end
