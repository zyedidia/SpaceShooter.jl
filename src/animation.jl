type Animation
	sprite::Sprite
	current_frame::Int
	clock::Clock
	delay::Real # In seconds
	num_frames::Int
	image_name::String
	position::Vector2f
end

function Animation(image, pos, delay, num_frames)
	current_frame = 0
	sprite = Sprite()
	texture = manager.textures["$image$current_frame"]
	set_texture(sprite, texture)
	set_origin(sprite, Vector2f(get_size(texture).x / 2, get_size(texture).y / 2))
	scale(sprite, Vector2f(2.5 * X_SCALE, 2.5 * Y_SCALE))

	clock = Clock()
	Animation(sprite, current_frame, clock, delay, num_frames, image, pos)
end

function die(animation::Animation)
	index = find(animations::Array{Animation} .== animation)[1]
	splice!(animations::Array{Animation}, index)
end

function draw(window, animation::Animation)
	if (get_elapsed_time(animation.clock) |> as_seconds) > animation.delay
		animation.current_frame += 1
		if animation.current_frame > animation.num_frames
			die(animation)
			return
		end
		set_texture(animation.sprite, manager.textures["$(animation.image_name)$(animation.current_frame)"])
		set_position(animation.sprite, animation.position)
		restart(animation.clock)
	end

	draw(window, animation.sprite)

	lightshader = manager.shaders["lightshader"]
	set_parameter(lightshader, "frag_LightOrigin", animation.position)
	set_parameter(lightshader, "frag_LightColor", Vector3f(255, 153, 51))
	set_parameter(lightshader, "frag_LightAttenuation", 200 * ((animation.current_frame + 1) / animation.num_frames))
	states = RenderStates(SFML.blend_add, lightshader)

	draw(window, render_texture_sprite, states)
end
