extends Sprite2D

var max_airtime: float = randf_range(0.0, 1.2)
var fall_time: float = randf_range(0.0, 0.25)

var hspeed: float = 0.0
var vspeed: float = 0.0
var gravity: float = 0.0

var airtime: float = 0.0
var falling: bool = false
var fall: float = 0.0

# code is based on the iwbtg gamemaker remake
# but also not really
func _ready() -> void:
	# make it go in random directions just like the og game! weeeee
	var dir: float = float(randi_range(0, 35) * 10)
	var spd: float = randf_range(0.0, 6.0)
	var rad: float = deg_to_rad(dir)
	hspeed = cos(rad) * spd
	vspeed = -sin(rad) * spd
	gravity = randf_range(0.1, 0.3)

func _physics_process(delta: float) -> void:
	vspeed += gravity
	global_position += Vector2(hspeed, vspeed)
	
	airtime += delta
	if vspeed > 0.0:
		falling = true
		fall += delta
	# cuz theres no actual solid collisions n stuff and its a 2d flat field
	# this is to simulate the blood "landing" on the floor and sticking to it like in iwbtg
	if (falling and fall >= fall_time) or airtime >= max_airtime:
		_land()

func _land() -> void:
	hspeed = 0.0
	vspeed = 0.0
	gravity = 0.0
	
