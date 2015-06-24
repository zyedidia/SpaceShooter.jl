# Laser - SpaceShip
function collision(laser::Laser, ship::SpaceShip)
	if ship.color != laser.color
		lose_health(ship, 1)
		if ship.health <= 0
			add_explosion(get_position(ship.sprite))
			die(ship)
		end
		add_explosion(get_position(laser.sprite))
		die(laser)
	end
end

# Asteroid - SpaceShip
function collision(asteroid::Asteroid, ship::SpaceShip)
	lose_health(ship, 2)
	if ship.health <= 0
		add_explosion(get_position(ship.sprite))
		die(ship)
	end
	add_explosion(get_position(asteroid.sprite))
	die(asteroid)
end

# Asteroid - Laser
function collision(asteroid::Asteroid, laser::Laser)
	add_explosion(get_position(laser.sprite))
	split_or_die(asteroid)
	die(laser)
end

# Asteroid - Asteroid
function collision(asteroid1::Asteroid, asteroid2::Asteroid)
	time1 = get_elapsed_time(asteroid1.time_alive) |> as_seconds
	time2 = get_elapsed_time(asteroid2.time_alive) |> as_seconds

	if time1 > 2 && time2 > 2
		add_explosion(get_position(asteroid1.sprite))
		add_explosion(get_position(asteroid2.sprite))
		split_or_die(asteroid1)
		split_or_die(asteroid2)
	end
end

# Laser - Laser
function collision(laser1::Laser, laser2::Laser)
	die(laser1)
	die(laser2)
end

function check_collisions(obj::GameObject)
	if !(typeof(obj) <: SpaceShip)
		obj_bounds = get_globalbounds(obj.sprite)
		for other in game_objects::Array{GameObject}
			if other == obj continue end
			if typeof(obj) == Laser && typeof(other) == Asteroid
				continue
			end
			other_bounds = get_globalbounds(other.sprite)
			if intersects(obj_bounds, other_bounds)
				collision(obj, other)
			end
		end
	end
end
