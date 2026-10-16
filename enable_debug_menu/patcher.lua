local utils = require("gdpatch.utils")

GDPatch.patch_script_as_text("scenes/main/main.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[	if OS.has_feature("editor") and event.is_action_pressed("debug_menu") and !GameEvents.pausing:]]),
	utils.escape(
[[	if event.is_action_pressed("debug_menu") and !GameEvents.pausing:]], true)
	)
end)
