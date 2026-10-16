extends Control

class_name UndertaleDeath

@onready var player: Node = get_tree().root.get_node("Main/Entities/Player")
@onready var cursor_shatter: Node = $CursorShatter
@onready var cursor_shard: PackedScene = preload("res://gdpatch/mods/too_many_deaths/scenes/undertale/undertaleshatter.tscn")

const shatter_texutures: Dictionary = {
	"default": preload("res://gdpatch/mods/too_many_deaths/assets/undertale/cursorshatterdefault.png"),
	"brick": preload("res://gdpatch/mods/too_many_deaths/assets/undertale/cursorshatterbrick.png"),
	"vector": preload("res://gdpatch/mods/too_many_deaths/assets/undertale/cursorshattervector.png"),
	"null": preload("res://gdpatch/mods/too_many_deaths/assets/undertale/cursorshatternull.png"),
	"breakpoint": preload("res://gdpatch/mods/too_many_deaths/assets/undertale/cursorshatterbreakpoint.png"),
	"thread": preload("res://gdpatch/mods/too_many_deaths/assets/undertale/cursorshatterthread.png"),
	"admin": preload("res://gdpatch/mods/too_many_deaths/assets/undertale/cursorshatteradmin.png")
}

const STAT_LIST_UID: String = "uid://b7q8ym7p8jnew"
const CURSOR_SCENE_UID: String = "uid://bloqyq1l5lfnw"
const EXIT_BLACKOUT_SEC: float = 0.55

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blackout: ColorRect = %Blackout

@export var listening: bool = false

const TEXT_REVEAL_START: float = 2.1

var stat_list: StatList
var cursor: Cursor

var player_pos: Vector2

func _ready() -> void :
	cursor_shatter.texture = shatter_texutures[GameEvents.picked_class.id]
	hide_vignette()
	player.set_physics_process(false) # this prevents the player from moving after dying
	player_pos = get_viewport().get_canvas_transform() * player.global_position
	cursor_shatter.global_position = player_pos
	blackout.hide()
	GameEvents.abort_fullscreen_queue(false)
	GameEvents.set_mouse_confined(false)
	GameEvents.pause_game(0.1) # setting this to 0 causes it to just not work for some reason so 0.1 will have to do

	var round_manager: RoundManager = get_tree().get_first_node_in_group("round_manager")
	var meta_earned: float = PolicyManager.apply_reward_multiplier(
		floori(round_manager.round_kill_count / 20)
	)
	GameEvents.emit_currency_collected("Beanz", meta_earned)
	StatTracker.finish_run(false)
	MetaProgression.save()

	await GameEvents.paused_handled
	if not is_inside_tree() or GameEvents.returning_to_menu:
		return
	animation_player.play("new_animation")

func _process(_delta: float) -> void :
	# very aggressive way to make sure filter isnt happening
	# as even tho stop music calls disabling it it gets reenabled sometimes anyways
	if AudioServer.is_bus_effect_enabled(0, 0):
		AudioServer.set_bus_effect_enabled(0, 0, false)

func _input(event: InputEvent) -> void :
	if not listening or event.is_echo() or GameEvents.returning_to_menu:
		return

	if event.is_action_pressed("tab") or event.is_action_pressed("menu_shortcut"):
		toggle_stats()
		get_viewport().set_input_as_handled()
		return

	if is_instance_valid(stat_list):
		if event.is_action_pressed("close"):
			toggle_stats()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("left_click") or event.is_action_pressed("close"):
		on_quit_button_pressed()
		get_viewport().set_input_as_handled()

func toggle_stats() -> void :
	if GameEvents.returning_to_menu:
		return
	if is_instance_valid(stat_list):
		listening = false
		stat_list.disable_hovers()
		stat_list.queue_free()
		stat_list = null
		if is_instance_valid(cursor):
			if GameEvents.active_cursor == cursor:
				GameEvents.restore_cursor()
			cursor.queue_free()
			cursor = null
		await wait_for_input_release()
		if is_inside_tree() and not GameEvents.returning_to_menu:
			listening = true
		return

	var stat_list_scene: PackedScene = load(STAT_LIST_UID) as PackedScene
	stat_list = stat_list_scene.instantiate()
	stat_list.live_updates = false
	add_child(stat_list)
	stat_list.show_run_tasks()
	stat_list.position.x -= 6
	stat_list.close.connect(toggle_stats)

	var cursor_scene: PackedScene = load(CURSOR_SCENE_UID) as PackedScene
	cursor = cursor_scene.instantiate() as Cursor
	add_child(cursor)
	cursor.position = Vector2(size.x * 0.5, size.y * 0.45)
	cursor.reset_physics_interpolation()

	await get_tree().process_frame
	if not is_inside_tree() or GameEvents.returning_to_menu:
		return
	if is_instance_valid(stat_list) and is_instance_valid(cursor):
		stat_list.enable_hovers(cursor)

func wait_for_input_release() -> void :
	if not is_inside_tree():
		return
	await get_tree().process_frame
	while is_inside_tree() and (Input.is_action_pressed("left_click") or Input.is_action_pressed("close") or Input.is_action_pressed("tab")):
		await get_tree().process_frame

func on_quit_button_pressed() -> void :
	if not listening or GameEvents.menu_return_started:
		return
	listening = false
	set_process_input(false)
	animation_player.stop()
	blackout.show()
	blackout.move_to_front()
	if is_instance_valid(stat_list):
		stat_list.disable_hovers()
		stat_list.queue_free()
		stat_list = null
	if is_instance_valid(cursor):
		if GameEvents.active_cursor == cursor:
			GameEvents.restore_cursor()
		cursor.queue_free()
		cursor = null
	print("return_to_menu: bluescreen")
	GameEvents.return_to_main_menu(false, EXIT_BLACKOUT_SEC)

func stop_music() -> void :
	MusicPlayer.halt()
	AudioServer.set_bus_effect_enabled(0, 0, false)

func hide_vignette() -> void :
	var vignette: CanvasItem = get_tree().get_first_node_in_group("vignette") as CanvasItem
	if vignette:
		vignette.hide()

func heart_kaboom() -> void:
	cursor_shatter.visible = false
	create_shard(Vector2(-2, 0))
	create_shard(Vector2(0, 3))
	create_shard(Vector2(2, 6))
	create_shard(Vector2(8, 0))
	create_shard(Vector2(10, 3))
	create_shard(Vector2(12, 6))

func create_shard(offset: Vector2) -> void:
	var shard: Object = cursor_shard.instantiate()
	shard.global_position = player_pos + offset
	add_child(shard)
