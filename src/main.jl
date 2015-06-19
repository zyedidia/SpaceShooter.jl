importall SFML

abstract GameObject

include("util.jl")
include("resourceManager.jl")
include("animation.jl")
include("laser.jl")
include("asteroid.jl")
include("spaceship.jl")

const GAME_PATH = dirname(Base.source_path()) * "/.."
real_width = get_desktop_mode().width
const mode = VideoMode(real_width, Uint32(round(real_width * 0.5625)))
# const mode = get_desktop_mode()

const SCREEN_WIDTH = Int(mode.width)
const SCREEN_HEIGHT = Int(mode.height)

const X_SCALE = SCREEN_WIDTH / 2560
const Y_SCALE = SCREEN_HEIGHT / 1440

const manager = load_files()

const MAX_SHIP_SPEED = 4
const SHIP_ACCELERATION = 0.05
const SHOT_COOLDOWN = 1 # In seconds
const SHIP_ROTATE_SPEED = 1

const LASER_SPEED = 10

const NUM_ASTEROIDS = 5

function spawn_asteroid(pos = Vector2f(rand(0:SCREEN_WIDTH), rand(0:SCREEN_HEIGHT)), scale_factor = 1)
	asteroid = Asteroid("meteorBrown_big$(rand(1:4))", pos, scale_factor)
	push!(game_objects::Array{GameObject}, asteroid)
end

function add_explosion(pos)
	explosion = Animation("expl_01_", pos, 0.05, 23)
	push!(animations::Array{Animation}, explosion)
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

	player1 = PlayerShip("playerShip1_red", [KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE],
			  			  start_pos = Vector2f(SCREEN_WIDTH - 100 * X_SCALE, SCREEN_HEIGHT - 100 * Y_SCALE))
	player2 = PlayerShip("playerShip1_blue", [KeyCode.W, KeyCode.S, KeyCode.A, KeyCode.D, KeyCode.LSHIFT],
						  start_pos = Vector2f(100 * X_SCALE, 100 * Y_SCALE), start_rot = 180)

	global game_objects = GameObject[]
	global lasers = Laser[]
	global animations = Animation[]
	push!(game_objects, player1)
	push!(game_objects, player2)

	for i = 1:NUM_ASTEROIDS
		spawn_asteroid()
	end

	background = Sprite()
	set_texture(background, manager.textures["black"])
	scale(background, Vector2f(10 * X_SCALE, 10 * Y_SCALE))

	lightshader = manager.shaders["lightshader"]
	set_parameter(lightshader, "frag_ScreenResolution", Vector2f(SCREEN_WIDTH, SCREEN_HEIGHT))

	set_loop(manager.music["space_music"], true)
	play(manager.music["space_music"])

	frame_clock = Clock()

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
			end
		end

		clear(render_texture, SFML.white)
		draw(render_texture, background)

		for obj in game_objects::Array{GameObject}
			update(obj, dt)
			draw(render_texture, obj)
		end

		for laser in lasers::Array{Laser}
			update(laser, dt)
			draw(render_texture, laser)
		end

		for animation in animations::Array{Animation}
			draw(render_texture, animation)
		end

		display(render_texture)

		clear(window, SFML.white)
		draw(window, render_texture_sprite)
		display(window)
	end
end

main()
