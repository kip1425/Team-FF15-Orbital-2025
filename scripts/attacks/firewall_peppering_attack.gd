extends Area2D

var speed := 100.0
var range := 1000.0
var level := 1
var damage := 2
var attack_size := 1.0
var exploded := false

var target := Vector2.ZERO
var angle := Vector2.ZERO

func _ready() -> void:
	$Fireball.play("default")
	if target == Vector2.ZERO:
		queue_free()
	angle = global_position.direction_to(target)
	rotation = angle.angle()
	match level:
		1:
			damage = 2
			attack_size = 1.0
		2:
			damage = 3
			attack_size = 1.2
		3:
			damage = 4
			attack_size = 1.4

@onready var fireball_sprite = $Fireball
@onready var explosion_sprite = $Explosion
@onready var collision_shape = $CollisionShape2D

func _update_attack_size():
	var scale_value = Vector2(attack_size, attack_size)
	if fireball_sprite && explosion_sprite:
		fireball_sprite.scale = scale_value
		explosion_sprite.scale = scale_value
	if collision_shape and collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size *= attack_size

var travelled_distance := 0.0
func _physics_process(delta: float) -> void:
	if exploded:
		return
	
	var movement = angle * speed * delta
	global_position += movement
	travelled_distance += movement.length()
	
	if travelled_distance > range:
		queue_free()
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	

var enemies_in_aoe = []

func explode() -> void:
	exploded = true
	$Fireball.visible = false
	$Explosion.visible = true
	$Explosion.play("default")
	for body in get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		explode()

func _on_explosion_animation_finished() -> void:
	queue_free()
