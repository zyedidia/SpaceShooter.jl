importall SFML

abstract GameObject

include("util.jl")
include("resourceManager.jl")
include("laser.jl")
include("asteroid.jl")
include("spaceship.jl")

const GAME_PATH = dirname(Base.source_path()) * "/.."
const mode = get_desktop_mode()

const SCREEN_WIDTH = Int(mode.width)
const SCREEN_HEIGHT = Int(mode.height)

const X_SCALE = SCREEN_WIDTH / 2560
const Y_SCALE = SCREEN_HEIGHT / 1440

const manager = load_files()

const MAX_SHIP_SPEED = 4
const SHIP_ACCELERATION = 0.05
const SHOT_COOLDOWN = 0.25 # In seconds
const SHIP_ROTATE_SPEED = 1

const LASER_SPEED = 10

const NUM_ASTEROIDS = 10

function spawn_asteroid()
	asteroid = Asteroid("meteorBrown_big$(rand(1:4))", Vector2f(rand(0:SCREEN_WIDTH), rand(0:SCREEN_HEIGHT)))
	push!(game_objects::Array{GameObject}, asteroid)
end

function main()
	settings = ContextSettings()
	settings.antialiasing_level = 3
	window = RenderWindow(mode, "Space Shooter", settings, window_fullscreen)
	set_vsync_enabled(window, true)
	set_framerate_limit(window, 60)
	event = Event()

	player = PlayerShip("playerShip1_blue")

	global game_objects = GameObject[]
	global lasers = Laser[]
	push!(game_objects, player)

	for i = 1:NUM_ASTEROIDS
		spawn_asteroid()
	end

	background = Sprite()
	set_texture(background, manager.textures["darkPurple"])
	scale(background, Vector2f(10 * X_SCALE, 10 * Y_SCALE))

	frame_clock = Clock()

	while isopen(window)
		dt = (get_elapsed_time(frame_clock) |> as_seconds) * 100
		restart(frame_clock)

		while pollevent(window, event)
			if get_type(event) == EventType.CLOSED
				close(window)
			end
		end

		clear(window, SFML.white)

		draw(window, background)

		for obj in game_objects::Array{GameObject}
			update(obj, dt)
			draw(window, obj)
		end

		for laser in lasers::Array{Laser}
			update(laser, dt)
			draw(window, laser)
		end

		display(window)
	end
end

main()
