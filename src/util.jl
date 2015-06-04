function wrap_position(sprite::Sprite)
	pos = get_position(sprite)
	size = get_size(get_texture(sprite))
	if pos.x > SCREEN_WIDTH + size.x / 2
		pos.x = 0 - size.x / 2
	elseif pos.x < 0 - size.x / 2
		pos.x = SCREEN_WIDTH + size.x / 2
	end

	if pos.y > SCREEN_HEIGHT + size.y / 2
		pos.y = 0 - size.y / 2
	elseif pos.y < 0 - size.y / 2
		pos.y = SCREEN_HEIGHT + size.y / 2
	end

	set_position(sprite, pos)
end
