local utils = require("gdpatch.utils")

-- weapon effect pool patches
-- create alpha holder node and use that for transparency
-- this is like the easiest approach to this while not breaking animations
GDPatch.patch_script_as_text("scenes/autoload/weapon_effect_pool.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[func spawn(scene: PackedScene, parent: Node) -> Node:
	var pool_key: String = scene.resource_path
	var effect: Node = take_from_pool(pool_key, scene)
	move_to_parent(effect, parent)]]),
	utils.escape(
[[func spawn(scene: PackedScene, parent: Node, alpha: float = GDPatch.get_config_option("let_me_see", "visibility", "alpha")) -> Node:
	var pool_key: String = scene.resource_path
	var effect: Node = take_from_pool(pool_key, scene)
	if is_equal_approx(alpha, 1.0):
		move_to_parent(effect, parent)
	else:
		var holder: Node2D = Node2D.new()
		holder.name = "AlphaHolder"
		holder.modulate.a = 0.5
		holder.add_to_group("alpha_holder")
		move_to_parent(holder, parent)
		move_to_parent(effect, holder)]], true)
	)
end)
-- this part is needed or else the nodes never properly free up
-- not having this will cause like a million extra nodes that r just forever stuck in ur game
GDPatch.patch_script_as_text("scenes/autoload/weapon_effect_pool.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[	deactivate_parked(effect)
	move_to_parent(effect, self)]]),
	utils.escape(
[[	deactivate_parked(effect)
	var holder: Node = effect.get_parent()
	move_to_parent(effect, self)
	if holder != null and holder != self and holder.is_in_group("alpha_holder"):
		holder.queue_free()]], true)
	)
end)

-- enemy bullet spawn patches
-- because some enemy bullets unfortunately use the same spawn code as the players weapons
-- the best way i can think of separating the two is by force setting 1.0 alpha on those spawns
-- at least from reading sauce code this is the only thing i need to do : 3
GDPatch.patch_script_as_text("scenes/component/shooter_component.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[		var projectile: Projectile = WeaponEffectPool.spawn(load(PROJECTILE_PATH) as PackedScene, owner_enemy.entities_layer) as Projectile]]),
	utils.escape(
[[		var projectile: Projectile = WeaponEffectPool.spawn(load(PROJECTILE_PATH) as PackedScene, owner_enemy.entities_layer, 1.0) as Projectile]], true)
	)
end)

-- solitaire trail patch
GDPatch.patch_script_as_text("scenes/ability/solitaire_ability/solitaire_trails.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[func _ready() -> void :]]),
	utils.escape(
[[func _ready() -> void :
	if GDPatch.get_config_option("let_me_see", "visibility", "solitaire_trail"):
		modulate.a = 0.0
	else:
		modulate.a = GDPatch.get_config_option("let_me_see", "visibility", "alpha")]], true)
	)
end)

-- scimitar patch
-- for some reason this is in a completely different spot compared to any other weapon??
GDPatch.patch_script_as_text("scenes/ability/scimitar_ability/scimitar_ability.gdc", function(ctx, src)
return src:gsub(
	utils.escape(
[[	modulate = Color.WHITE]]),
	utils.escape(
[[	modulate = Color.WHITE
	modulate.a = GDPatch.get_config_option("let_me_see", "visibility", "alpha")]], true)
	)
end)
