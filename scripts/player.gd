class_name Player extends CharacterBody2D

const SPEED = 180.0
const MAX_HEALTH = 100
var current_health = MAX_HEALTH
var is_dead = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $"../PlayerUI/HealthBar" # i think correct path

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# gravity physics logic removed here
	if is_dead:
		return 
	
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

# position smoothing turned off to not mess up player HUD at the moment

func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		die()
	update_health_bar()
		
func update_health_bar() -> void:
	if health_bar:
		health_bar.value = current_health

func die() -> void:
	is_dead = true
	Engine.time_scale = 0.0
	set_process(false)
	set_physics_process(false)
	
	var game_over_ui = get_node("Camera2D/GameOver")
	if game_over_ui:
		game_over_ui.show()
	else:
		print("game over node not found!")
	
	
	
	
