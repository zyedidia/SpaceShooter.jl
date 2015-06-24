@_type Asteroid GameObject begin
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
end

function update_pos(asteroid::Asteroid, dt)
	wrap_position(asteroid.sprite)

	velocity = Vector2f(asteroid.speed * cosd(asteroid.angle - 90) * dt * X_SCALE, asteroid.speed * sind(asteroid.angle - 90) * dt * Y_SCALE)
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

function draw(window, asteroid::Asteroid)
	draw(window, asteroid.sprite)
end
