type Asteroid <: GameObject
	sprite::Sprite
	speed::Real
	moveangle::Real
	rotate_speed::Real
	time_alive::Clock
end

function Asteroid(texture_name, pos, scale_factor = 1)
	sprite = Sprite()
	texture = manager.textures[texture_name]
	set_texture(sprite, texture)
	set_origin(sprite, Vector2f(get_size(texture).x / 2, get_size(texture).y / 2))
	set_position(sprite, pos)
	scale(sprite, Vector2f(X_SCALE * scale_factor, Y_SCALE * scale_factor))

	Asteroid(sprite, rand(2:6), rand(0:360), rand(0:3), Clock())
end

function update(asteroid::Asteroid, dt)
	update_pos(asteroid, dt)
	check_collision(asteroid)
end

function update_pos(asteroid::Asteroid, dt)
	wrap_position(asteroid.sprite)

	velocity = Vector2f(asteroid.speed * cosd(asteroid.moveangle - 90) * dt * X_SCALE, asteroid.speed * sind(asteroid.moveangle - 90) * dt * Y_SCALE)
	rotate(asteroid.sprite, asteroid.rotate_speed * dt)
	move(asteroid.sprite, velocity)
end

function split_or_die(asteroid::Asteroid)
	size = get_globalbounds(asteroid.sprite)
	if size.width < 80 * X_SCALE
		die(asteroid)
	else
		spawn_asteroid(get_position(asteroid.sprite), get_scale(asteroid.sprite).x / X_SCALE / 2)
		scale(asteroid.sprite, Vector2f(0.5, 0.5))
	end
end

function check_collision(asteroid::Asteroid)
	asteroid_bounds = get_globalbounds(asteroid.sprite)
	for obj in game_objects::Array{GameObject}
		if obj != asteroid
			obj_bounds = get_globalbounds(obj.sprite)
			if intersects(obj_bounds, asteroid_bounds)
				asteroid_collision(obj, asteroid)
			end
		end
	end
end

function asteroid_collision(asteroid1::Asteroid, asteroid2::Asteroid)
	time1 = get_elapsed_time(asteroid1.time_alive) |> as_seconds
	time2 = get_elapsed_time(asteroid2.time_alive) |> as_seconds

	if time1 > 2 && time2 > 2
		add_explosion(get_position(asteroid1.sprite))
		add_explosion(get_position(asteroid2.sprite))
		split_or_die(asteroid1)
		split_or_die(asteroid2)
	end
end

function laser_collision(asteroid::Asteroid, laser::Laser)
	add_explosion(get_position(laser.sprite))
	split_or_die(asteroid)
	die(laser)
end

function draw(window, asteroid::Asteroid)
	draw(window, asteroid.sprite)
end
