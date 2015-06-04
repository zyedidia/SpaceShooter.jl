type ResourceManager
	sound_effects::Dict{String, SoundBuffer}
	music::Dict{String, Music}
	textures::Dict{String, Texture}
	font::Font
end

filename(f) = f[1:search(f, ".")[1]-1]

function load_files()
	sounds = load_sound_effects()
	music = load_music()
	textures = load_textures()
	font = Font(GAME_PATH * "/assets/font/kenvector_future.ttf")
	manager = ResourceManager(sounds, music, textures, font)
end

function load_sound_effects(path = "sound")
	sounds = Dict{String, SoundBuffer}()

	soundfiles = readdir(GAME_PATH * "/assets/$path")
	for file in soundfiles
		sounds[filename(file)] = SoundBuffer(GAME_PATH * "/assets/$path/$file")
	end
	sounds
end

function load_music(path = "music")
	music = Dict{String, Music}()
end

function load_textures(path = "img")
	textures = Dict{String, Texture}()

	files = readdir(GAME_PATH * "/assets/$path")
	for file in files
		if isdir(GAME_PATH * "/assets/$path/$file")
			innerfiles = readdir(GAME_PATH * "/assets/$path/$file")
			for innerfile in innerfiles
				texture = Texture(GAME_PATH * "/assets/$path/$file/$innerfile")
				textures[filename(innerfile)] = texture
				set_smooth(texture, true)
			end
		else
			texture = Texture(GAME_PATH * "/assets/$path/$file")
			textures[filename(file)] = texture
			set_smooth(texture, true)
		end
	end
	textures
end

