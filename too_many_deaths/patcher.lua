local utils = require("gdpatch.utils")

GDPatch.patch_script_as_text("scenes/main/main.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[const BLUE_SCREEN_UID: String = "uid://ccrqllopuays2"]]),
	utils.escape(
[[var deaths_array: Array
const BLUE_SCREEN_UID: String = "uid://ccrqllopuays2"]], true)
	)
end)

GDPatch.patch_script_as_text("scenes/main/main.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[func _ready() -> void :]]),
	utils.escape(
[[func _ready() -> void :
	if GDPatch.get_config_option("too_many_deaths", "death_screens", "bluescreen"):
		deaths_array.append("uid://ccrqllopuays2")
	if GDPatch.get_config_option("too_many_deaths", "death_screens", "iwbtg"):
		deaths_array.append("res://gdpatch/mods/too_many_deaths/scenes/iwbtgdeath.tscn")]], true)
	)
end)

GDPatch.patch_script_as_text("scenes/main/main.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[	var blue_screen_scene: PackedScene = load(BLUE_SCREEN_UID) as PackedScene
	var blue_screen_instance: BlueScreen = blue_screen_scene.instantiate()
	GameEvents.spawn_overlay(blue_screen_instance)]]),
	utils.escape(
[[	var pick_death: String = deaths_array.pick_random()
	var death_screen_scene: PackedScene = load(pick_death) as PackedScene
	var death_screen_instance: Node = death_screen_scene.instantiate()
	GameEvents.spawn_overlay(death_screen_instance)]], true)
	)
end)
