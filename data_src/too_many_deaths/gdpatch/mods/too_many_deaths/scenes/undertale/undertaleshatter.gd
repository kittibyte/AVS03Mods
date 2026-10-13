extends Node2D

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	var rad: float = deg_to_rad(randf() * 360.0)
	velocity = Vector2(cos(rad), -sin(rad)) * 7.0 * 30.0

func _physics_process(delta: float) -> void:
	velocity += Vector2.DOWN * 0.2 * 30.0 * 30.0 * delta
	position += velocity * delta
