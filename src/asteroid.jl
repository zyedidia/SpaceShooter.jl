type Asteroid <: GameObject
	sprite::Sprite
	speed::Real
	moveangle::Real
	rotate_speed::Real
end

function Asteroid(texture_name, pos, factors = 1)
	sprite = Sprite()
	texture = manager.textures[texture_name]
	set_texture(sprite, texture)
	set_origin(sprite, Vector2f(get_size(texture).x / 2, get_size(texture).y / 2))
	set_position(sprite, pos)
	scale(sprite, Vector2f(X_SCALE * factors, Y_SCALE * factors))

	Asteroid(sprite, rand(2:6), rand(0:360), rand(0:3))
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
	# Do nothing
end

function laser_collision(asteroid::Asteroid, laser::Laser)
	add_explosion(get_position(laser.sprite))
	size = get_globalbounds(asteroid.sprite)
	if size.width < 100 * X_SCALE
		die(asteroid)
	else
		spawn_asteroid(get_position(asteroid.sprite), get_scale(asteroid.sprite).x / X_SCALE / 2)
		scale(asteroid.sprite, Vector2f(0.5, 0.5))
	end
	die(laser)
end

function die(asteroid::Asteroid)
	index = find(game_objects::Array{GameObject} .== asteroid)
	if length(index) > 0
		splice!(game_objects::Array{GameObject}, index[1])
	end
end

function draw(window, asteroid::Asteroid)
	draw(window, asteroid.sprite)
end
