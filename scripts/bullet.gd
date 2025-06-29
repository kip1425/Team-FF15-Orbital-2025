extends Area2D

const SPEED := 200.0
const RANGE := 1000.0
var damage := 1

var travelled_distance := 0.0
@onready var direction := Vector2.RIGHT.rotated(rotation)

func _process(delta: float) -> void:
	var movement = direction * SPEED * delta
	position += movement
	travelled_distance += movement.length()

	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
