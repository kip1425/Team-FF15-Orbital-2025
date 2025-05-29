extends CharacterBody2D

const SPEED = 180.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# gravity physics logic removed here
	var input_vector := Vector2(
		Input.get_action_strength("moveright") - Input.get_action_strength("moveleft"),
		Input.get_action_strength("movedown") - Input.get_action_strength("moveup")
	).normalized()
	
	velocity = input_vector * SPEED
	move_and_slide()
	
	# Animation handling
	if input_vector != Vector2.ZERO:
		animated_sprite_2d.play("run")

		# flip direction of sprite
		if abs(input_vector.x) > abs(input_vector.y):
			animated_sprite_2d.flip_h = input_vector.x < 0
		# additional up / down animations will go here
	else:
		animated_sprite_2d.play("idle")
