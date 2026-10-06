local utils = require("gdpatch.utils")

GDPatch.patch_script_as_text("scenes/game_object/clickables/keygen_file/keygen_window.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[func _ready() -> void :]]),
	utils.escape(
[[func _ready() -> void :
	var keygenstream: AudioStreamPlayer = AudioStreamPlayer.new()
	var keygensound: AudioStreamWAV = load("res://gdpatch/mods/king_downloads_sonyvegas/assets/keygen.wav")
	add_child(keygenstream)
	keygenstream.set_stream(keygensound)
	keygenstream.bus = "sfx"
	keygenstream.play()]], true)
	)
end)

GDPatch.patch_script_as_text("scenes/game_object/clickables/keygen_file/keygen_window.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[func finished() -> void :]]),
	utils.escape(
[[func finished() -> void :
	var hoahstream: AudioStreamPlayer = AudioStreamPlayer.new()
	var hoahsound: AudioStreamWAV = load("res://gdpatch/mods/king_downloads_sonyvegas/assets/hoah.wav")
	add_child(hoahstream)
	hoahstream.set_stream(hoahsound)
	hoahstream.bus = "sfx"
	hoahstream.play()]], true)
	)
end)
