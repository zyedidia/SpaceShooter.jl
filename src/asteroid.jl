type Asteroid <: GameObject
	sprite::Sprite
	speed::Real
	moveangle::Real
	rotate_speed::Real
end

function Asteroid(texture_name, pos)
	sprite = Sprite()
	texture = manager.textures[texture_name]
	set_texture(sprite, texture)
	set_origin(sprite, Vector2f(get_size(texture).x / 2, get_size(texture).y / 2))
	set_position(sprite, pos)
	scale(sprite, Vector2f(X_SCALE, Y_SCALE))

	Asteroid(sprite, rand(2:6), rand(0:360), rand(0:3))
end

function update(asteroid::Asteroid, dt)
	update_pos(asteroid, dt)
end

function update_pos(asteroid::Asteroid, dt)
	wrap_position(asteroid.sprite)

	velocity = Vector2f(asteroid.speed * cosd(asteroid.moveangle - 90) * dt * X_SCALE, asteroid.speed * sind(asteroid.moveangle - 90) * dt * Y_SCALE)
	rotate(asteroid.sprite, asteroid.rotate_speed * dt)
	move(asteroid.sprite, velocity)
end

function laser_collision(asteroid::Asteroid, laser::Laser)
	add_explosion(get_position(laser.sprite))
	die(asteroid)
	die(laser)
end

function die(asteroid::Asteroid)
	index = find(game_objects::Array{GameObject} .== asteroid)[1]
	splice!(game_objects::Array{GameObject}, index)
end

function draw(window, asteroid::Asteroid)
	draw(window, asteroid.sprite)
end
