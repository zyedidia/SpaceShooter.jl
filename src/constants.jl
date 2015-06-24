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

const NUM_ASTEROIDS = 10
const ENEMY_SPAWN_TIME = 5 # In seconds
