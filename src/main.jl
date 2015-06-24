importall SFML

abstract GameObject

include("resourceManager.jl")
include("constants.jl")
include("util.jl")
include("animation.jl")
include("laser.jl")
include("asteroid.jl")
include("spaceship.jl")
include("collision.jl")

function spawn_asteroid(pos = Vector2f(rand(0:SCREEN_WIDTH), rand(0:SCREEN_HEIGHT)), scale_factor = 1)
	asteroid = Asteroid("meteorBrown_big$(rand(1:4))", pos, scale_factor)
	push!(game_objects::Array{GameObject}, asteroid)
end

function add_explosion(pos)
	play(Sound(manager.sound_effects["explosion2"]))
	explosion = Animation("expl_01_", pos, 0.05, 23)
	push!(animations::Array{Animation}, explosion)
end

function add_enemy()
	enemy = EnemyShip("ufoRed", start_pos = Vector2f(rand(0:SCREEN_WIDTH), rand(0:SCREEN_HEIGHT)))
	push!(game_objects::Array{GameObject}, enemy)
end

function drawlight(window, pos, color, attenuation)
	lightshader = manager.shaders["lightshader"]
	set_parameter(lightshader, "frag_LightOrigin", pos)
	set_parameter(lightshader, "frag_LightColor", Vector3f(color.r, color.g, color.b))
	set_parameter(lightshader, "frag_LightAttenuation", attenuation)
	states = RenderStates(SFML.blend_add, lightshader)

	draw(window, render_texture_sprite, states)
end

function main()
	settings = ContextSettings()
	settings.antialiasing_level = 3
	window = RenderWindow(mode, "Space Shooter", settings, window_defaultstyle)
	set_vsync_enabled(window, true)
	set_framerate_limit(window, 60)
	event = Event()

	render_texture = RenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
	# This needs to be global so I can access it for drawing shaders
	global const render_texture_sprite = Sprite()
	set_texture(render_texture_sprite, get_texture(render_texture))

	# These will be initialized for real in init_world()
	player1 = 0
	# Second player?
	# player2 = 0
	start_pos = 0
	frame_clock = 0
	enemyspawn_clock = 0

	function init_world()
		player1 = PlayerShip("playerShip1_blue", [KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE],
		start_pos = Vector2f(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2))
		# player2 = PlayerShip("playerShip1_red", [KeyCode.W, KeyCode.S, KeyCode.A, KeyCode.D, KeyCode.LSHIFT],
		# 					  start_pos = Vector2f(100 * X_SCALE, 100 * Y_SCALE), start_rot = 180)

		global game_objects = GameObject[]
		global animations = Animation[]
		push!(game_objects, player1)
		# push!(game_objects, player2)

		for i = 1:NUM_ASTEROIDS
			spawn_asteroid()
		end

		frame_clock = Clock()
		enemyspawn_clock = Clock()
	end

	init_world()

	win_text = RenderText()
	set_string(win_text, "You win!")
	set_charactersize(win_text, 75)
	bounds = get_globalbounds(win_text)
	set_origin(win_text, Vector2f(bounds.width / 2, bounds.height / 2))
	set_color(win_text, SFML.red)
	set_position(win_text, Vector2f(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2))

	restart_text = copy(win_text)
	set_string(restart_text, "Press enter to restart")
	move(restart_text, Vector2f(0, bounds.height))
	bounds = get_globalbounds(restart_text)
	set_origin(restart_text, Vector2f(bounds.width / 2, bounds.height / 2))

	background = Sprite()
	set_texture(background, manager.textures["black"])
	scale(background, Vector2f(10 * X_SCALE, 10 * Y_SCALE))

	lightshader = manager.shaders["lightshader"]
	set_parameter(lightshader, "frag_ScreenResolution", Vector2f(SCREEN_WIDTH, SCREEN_HEIGHT))

	set_loop(manager.music["space_music"], true)
	play(manager.music["space_music"])

	while isopen(window)
		dt = (get_elapsed_time(frame_clock) |> as_seconds) * 100
		restart(frame_clock)

		while pollevent(window, event)
			if get_type(event) == EventType.CLOSED
				close(window)
			elseif get_type(event) == EventType.KEY_PRESSED
				if get_key(event).key_code == KeyCode.ESCAPE
					close(window)
				end
				if get_key(event).key_code == KeyCode.RETURN
					init_world()
				end
			end
		end

		if (get_elapsed_time(enemyspawn_clock) |> as_seconds) > ENEMY_SPAWN_TIME
			add_enemy()
			restart(enemyspawn_clock)
		end

		clear(render_texture, SFML.white)
		draw(render_texture, background)

		num_asteroids = 0
		for obj in game_objects::Array{GameObject}
			if typeof(obj) == Asteroid
				num_asteroids += 1
			end

			check_collisions(obj)

			update(obj, dt)
			draw(render_texture, obj)
		end

		for animation in animations::Array{Animation}
			draw(render_texture, animation)
		end

		if num_asteroids == 0
			draw(render_texture, win_text)
			draw(render_texture, restart_text)
		end

		display(render_texture)

		clear(window, SFML.white)
		draw(window, render_texture_sprite)
		display(window)
	end
end

main()
