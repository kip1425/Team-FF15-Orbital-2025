extends Area2D

var speed := 100.0
var range := 1000.0
var hp := 2 # number of enemies pierced
var level := 1
var damage := 2
var attack_size := 1.0

var target := Vector2.ZERO
var angle := Vector2.ZERO

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	if target == Vector2.ZERO:
		queue_free()
	angle = global_position.direction_to(target)
	rotation = angle.angle()
	match level:
		1:
			hp = 2
			damage = 2
			attack_size = 1.0

var travelled_distance := 0.0
func _physics_process(delta: float) -> void:
	var movement = angle * speed * delta
	global_position += movement
	travelled_distance += movement.length()
	
	if travelled_distance > range:
		queue_free()
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
func enemy_hit(charge := 1) -> void:
	hp -= charge
	if hp <= 0:
		queue_free()
		
func _on_body_entered(body: Node2D) -> void:
	if body is Mob and body.has_method("take_damage"):
		body.take_damage(damage)
		enemy_hit()
