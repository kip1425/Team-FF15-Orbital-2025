extends Area2D

var speed := 100.0
var range := 1000.0
var level := 1
var damage := 2
var knockback_amount := 50.0
var attack_size := 1.0

var last_movement := Vector2.ZERO
var angle := Vector2.ZERO
var angle_less := Vector2.ZERO
var angle_more := Vector2.ZERO

var travelled_distance := 0.0
@onready var direction := Vector2.RIGHT.rotated(rotation)

func _process(delta: float) -> void:
	var movement = direction * speed * delta
	position += movement
	travelled_distance += movement.length()

	if travelled_distance > range:
		queue_free()

func _physics_process(delta: float) -> void:
	
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		for i in damage:
			body.take_damage()
		
	queue_free()

func _ready() -> void:
	match level:
		1:
			var damage := 2
			var knockback_amount := 50.0
			var attack_size := 1.0
	
	var move_to_less := Vector2.ZERO
	var move_to_more := Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1, -0.25), global_position.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), global_position.y) * 500
		Vector2.LEFT, Vector2.RIGHT:
			move_to_less = global_position + Vector2(global_position.x, randf_range(-1, -0.25)) * 500
			move_to_more = global_position + Vector2(global_position.x, randf_range(0.25, 1)) * 500
		Vector2(1, 1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * 500
	
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
