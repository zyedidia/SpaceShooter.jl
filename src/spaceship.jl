abstract SpaceShip <: GameObject

type PlayerShip <: SpaceShip
	sprite::Sprite
	speed::Real
	angle::Real
	health::Int
	cooldown_clock::Clock
	color::String
	healthbar::RectangleShape
	keys::Array{Int}
end

type EnemyShip <: SpaceShip
	sprite::Sprite
	speed::Real
	angle::Real
	health::Int
	cooldown_clock::Clock
	color::String
	healthbar::RectangleShape
	target_pos::Vector2f
end

function SpaceShip(texture_name, start_pos, start_rot)
	sprite = Sprite()
	texture = manager.textures[texture_name]
	set_texture(sprite, texture)
	set_origin(sprite, Vector2f(get_size(texture).x / 2, get_size(texture).y / 2))
	set_position(sprite, start_pos)
	scale(sprite, Vector2f(X_SCALE, Y_SCALE))

	color = ""
	if ismatch(r"(b|B)lue", texture_name)
		color = "Blue"
	elseif ismatch(r"(R|r)ed", texture_name)
		color = "Red"
	elseif ismatch(r"(G|g)reen", texture_name)
		color = "Green"
	end

	healthbar = RectangleShape()
	set_fillcolor(healthbar, eval(parse("SFML.$(lowercase(color))")))

	sprite, 0, start_rot, 10, Clock(), color, healthbar
end

function PlayerShip(texture_name::String, keys::Array{Int};
					start_pos = Vector2f(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2),
					start_rot = 0)
	r1, r2, r3, r4, r5, r6, r7 = SpaceShip(texture_name, start_pos, start_rot)
	PlayerShip(r1, r2, r3, r4, r5, r6, r7, keys)
end

function EnemyShip(texture_name; start_pos = Vector2f(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), start_rot = 0)
	r1, r2, r3, r4, r5, r6, r7 = SpaceShip(texture_name, start_pos, start_rot)
	EnemyShip(r1, r2, r3, 2, r5, r6, r7, start_pos)
end

function update(ship::SpaceShip, dt)
	handle_keys(ship, dt)
	update_pos(ship, dt)
end

function handle_keys(ship::PlayerShip, dt)
	if is_key_pressed(ship.keys[1])
		ship.speed += SHIP_ACCELERATION * dt
	elseif is_key_pressed(ship.keys[2])
		ship.speed -= SHIP_ACCELERATION * dt
	else
		if ship.speed > 0
			ship.speed -= SHIP_ACCELERATION * dt
		elseif ship.speed < 0
			ship.speed += SHIP_ACCELERATION * dt
		end
	end

	if is_key_pressed(ship.keys[3])
		ship.angle -= SHIP_ROTATE_SPEED * dt
	elseif is_key_pressed(ship.keys[4])
		ship.angle += SHIP_ROTATE_SPEED * dt
	end

	if is_key_pressed(ship.keys[5])
		shoot_laser(ship)
	end

	ship.speed = clamp(ship.speed, -MAX_SHIP_SPEED, MAX_SHIP_SPEED)
end

function handle_keys(ship::EnemyShip, dt)
	pos = get_position(ship.sprite)
	tpos = ship.target_pos
	if (tpos.x - 2 < pos.x < tpos.x + 2) && (tpos.y - 2 < pos.y < tpos.y + 2)
		ship.target_pos = Vector2f(rand(0:SCREEN_WIDTH), rand(0:SCREEN_HEIGHT))
	end

	trot = (rad2deg(atan2(pos.x - ship.target_pos.x, pos.y - ship.target_pos.y)))
	ship.angle = -trot
	ship.speed += SHIP_ACCELERATION * dt

	shoot_laser(ship, rand(0:360))

	ship.speed = clamp(ship.speed, -MAX_SHIP_SPEED, MAX_SHIP_SPEED)
end

function shoot_laser(ship::SpaceShip, angle = ship.angle)
	if (get_elapsed_time(ship.cooldown_clock) |> as_seconds) > SHOT_COOLDOWN
		restart(ship.cooldown_clock)
		l = Laser("laser$(ship.color)01", get_position(ship.sprite))
		l.angle = angle
		push!(game_objects::Array{GameObject}, l)

		play(Sound(manager.sound_effects["sfx_laser$(rand(1:2))"]))
	end
end

function update_pos(ship::SpaceShip, dt)
	wrap_position(ship.sprite)

	velocity = Vector2f(ship.speed * cosd(ship.angle - 90) * dt * X_SCALE, ship.speed * sind(ship.angle - 90) * dt * Y_SCALE)
	set_rotation(ship.sprite, ship.angle)
	move(ship.sprite, velocity)

	size = get_globalbounds(ship.sprite)
	pos = get_position(ship.sprite)
	set_position(ship.healthbar, Vector2f(pos.x - size.width / 2, pos.y - size.height / 2 - 10 * Y_SCALE))
end

function lose_health(ship::SpaceShip, amount)
	ship.health -= amount
	set_size(ship.healthbar, Vector2f(ship.health * 10 * X_SCALE, 10 * Y_SCALE))
end

function die(obj::GameObject)
	index = find(game_objects::Array{GameObject} .== obj)
	if length(index) > 0
		splice!(game_objects::Array{GameObject}, index[1])
	end
end

function draw(window, ship::SpaceShip)
	draw(window, ship.healthbar)
	draw(window, ship.sprite)
end
