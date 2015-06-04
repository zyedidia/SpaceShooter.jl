type ResourceManager
	sound_effects::Dict{String, SoundBuffer}
	music::Dict{String, Music}
	textures::Dict{String, Texture}
	shaders::Dict{String, Shader}
	font::Font
end

filename(f) = f[1:search(f, ".")[1]-1]

function load_files()
	sounds = load_sound_effects()
	music = load_music()
	textures = load_textures()
	shaders = load_shaders()
	font = Font(GAME_PATH * "/assets/font/kenvector_future.ttf")
	manager = ResourceManager(sounds, music, textures, shaders, font)
end

function load_sound_effects(path = "sound")
	sounds = Dict{String, SoundBuffer}()

	soundfiles = readdir(GAME_PATH * "/assets/$path")
	for file in soundfiles
		if ismatch(r".*\.(ogg|wav)", file)
			sounds[filename(file)] = SoundBuffer(GAME_PATH * "/assets/$path/$file")
		end
	end
	sounds
end

function load_music(path = "music")
	music = Dict{String, Music}()

	files = readdir(GAME_PATH * "/assets/$path")
	for file in files
		if ismatch(r".*\.ogg", file)
			music[filename(file)] = Music(GAME_PATH * "/assets/$path/$file")
		end
	end
	music
end

function load_textures(path = "img")
	textures = Dict{String, Texture}()

	files = readdir(GAME_PATH * "/assets/$path")
	for file in files
		if isdir(GAME_PATH * "/assets/$path/$file")
			innerfiles = readdir(GAME_PATH * "/assets/$path/$file")
			for innerfile in innerfiles
				if ismatch(r".*\.png", innerfile)
					texture = Texture(GAME_PATH * "/assets/$path/$file/$innerfile")
					textures[filename(innerfile)] = texture
					set_smooth(texture, true)
				end
			end
		else
			if ismatch(r".*\.png", file)
				texture = Texture(GAME_PATH * "/assets/$path/$file")
				textures[filename(file)] = texture
				set_smooth(texture, true)
			end
		end
	end
	textures
end

function load_shaders(path = "shaders")
	shaders = Dict{String, Shader}()

	files = readdir(GAME_PATH * "/assets/$path")
	for file in files
		if ismatch(r".*\.(vert|frag)", file)
			shaders[filename(file)] = Shader(GAME_PATH * "/assets/$path/$file")
		end
	end
	shaders
end
