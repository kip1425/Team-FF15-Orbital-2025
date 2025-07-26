extends Area2D
var speed := 20.0
var range := 1000.0
var level := 1
var damage := 1
var knockback_amount := 10

var zigzag_amount := 50.0
var zigzag_speed := 3 

var last_movement := Vector2.ZERO
var angle := Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	$Timer.start()
	$Cyclone.play("default")
	match level:
		1:
			damage = 1
			knockback_amount = 20
		2:
			damage = 2
			knockback_amount = 30
		3:
			damage = 3
			knockback_amount = 40

var travelled_distance := 0.0
func _physics_process(delta: float) -> void:
	var movement = angle * speed * delta
	global_position += movement
	travelled_distance += movement.length()
	
	var zigzag_offset = sin(travelled_distance * zigzag_speed / 100.0) * zigzag_amount
	var forward_movement = last_movement * speed * delta
	var side_movement = last_movement.rotated(PI/2) * zigzag_offset * delta
	
	angle = forward_movement + side_movement
	global_position += angle
	travelled_distance += forward_movement.length()
	
	if travelled_distance > range:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()

var already_hit := {}

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var id := str(body.get_instance_id())
		if already_hit.has(id):
			return
		body.take_damage(damage)
		var tween = create_tween()
		var knockback_position = body.global_position + angle.normalized() * knockback_amount
		tween.tween_property(body, "global_position", knockback_position, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		already_hit[id] = true
