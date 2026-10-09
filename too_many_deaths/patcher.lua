local utils = require("gdpatch.utils")

GDPatch.patch_script_as_text("scenes/main/main.gdc", function(ctx, src)
print(src)
return src:gsub(
	utils.escape(
[[const BLUE_SCREEN_UID: String = "uid://ccrqllopuays2"]]),
	utils.escape(
[[const BLUE_SCREEN_UID: PackedScene = preload("res://gdpatch/mods/too_many_deaths/scenes/iwbtgdeath.tscn")]], true)
	)
end)

GDPatch.patch_script_as_text("scenes/main/main.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[	var blue_screen_scene: PackedScene = load(BLUE_SCREEN_UID) as PackedScene]]),
	utils.escape(
[[	var blue_screen_scene: PackedScene = BLUE_SCREEN_UID]], true)
	)
end)
