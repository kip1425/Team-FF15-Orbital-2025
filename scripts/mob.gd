extends CharacterBody2D

var health = 3
var is_hurt = false
const SPEED = 75.0
@onready var player = get_node("/root/Game/Player")
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if is_hurt:
		move_and_slide()
		return
		
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED
	
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
	
	move_and_slide()

func take_damage():
	health -= 1
	animated_sprite.play("take_damage")
	# take damage animation here to be improved on

	if health == 0:
		queue_free()
		
		# fix enemy death animation later
		
		#const SMOKE_SCENE = preload("res://assets/smoke_explosion/smoke_explosion.tscn")
		#var smoke = SMOKE_SCENE.instantiate() 
		
		# smoke added as sibling node to mob
		#get_parent().add_child(smoke)
		#smoke.global_position = global_position
	
	
