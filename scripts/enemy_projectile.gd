extends Area2D

const SPEED := 200.0
const RANGE := 100.0

var travelled_distance := 0.0
var direction: Vector2 = Vector2.RIGHT

@export var damage: int = 20

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _process(delta: float) -> void:
	var movement = direction * SPEED * delta
	position += movement
	travelled_distance += movement.length()
	
	if travelled_distance > RANGE:
		queue_free()
func _on_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		if body.has_method("take_damage"):
			body.take_damage(damage)
	queue_free()
	
func init(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
