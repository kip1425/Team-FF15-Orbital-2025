class_name Player extends CharacterBody2D

const SPEED = 180.0
const MAX_HEALTH = 100
const ROLL_DURATION = 0.4
const ROLL_SPEED = 300.0
const ROLL_COOLDOWN = 1.0

var current_health = MAX_HEALTH
var is_dead = false

var is_rolling = false
var roll_direction = Vector2.ZERO
var roll_timer = 0.0
var roll_cooldown_timer = 0.0

var facing_direction: Vector2 = Vector2.RIGHT

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $"../PlayerUI/HealthBar" # i think correct path
@onready var roll_sound_player: AudioStreamPlayer2D = $RollSoundPlayer
@onready var take_dmg_sound_player: AudioStreamPlayer2D = $TakeDamageSound

func _ready() -> void:
	add_to_group("player")
	facing_direction = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	if is_dead:
		return 
	
	if roll_cooldown_timer > 0:
		roll_cooldown_timer -= delta
	
	if is_rolling:
		roll_timer -= delta
		velocity = roll_direction * ROLL_SPEED
		move_and_slide()
		animated_sprite_2d.play("roll")
		
		if roll_timer <= 0:
			is_rolling = false
		return
	
	var input_vector := Vector2(
		Input.get_action_strength("moveright") - Input.get_action_strength("moveleft"),
		Input.get_action_strength("movedown") - Input.get_action_strength("moveup")
	).normalized()
	
	if Input.is_action_just_pressed("roll") and roll_cooldown_timer <= 0:
		start_roll(input_vector)
		return
	
		
	if input_vector != Vector2.ZERO:
		facing_direction = input_vector.normalized()
	
	velocity = input_vector * SPEED
	move_and_slide()
	
	# Animation handling
	if input_vector != Vector2.ZERO:
		animated_sprite_2d.play("run")
		if abs(input_vector.x) > abs(input_vector.y):
			animated_sprite_2d.flip_h = input_vector.x < 0
	else:
		animated_sprite_2d.play("idle")

func start_roll(direction: Vector2) -> void:	
	roll_sound_player.play()
	
	if Input.is_action_pressed("moveleft") or Input.is_action_pressed("moveright") \
	or Input.is_action_pressed("moveup") or Input.is_action_pressed("movedown"):
		roll_direction = direction.normalized()
	else:
		# Roll strictly left or right based on facing_direction.x sign
		if facing_direction.x >= 0:
			roll_direction = Vector2.RIGHT
		else:
			roll_direction = Vector2.LEFT
	
	is_rolling = true
	roll_timer = ROLL_DURATION
	roll_cooldown_timer = ROLL_COOLDOWN

func take_damage(amount: int) -> void:
	take_dmg_sound_player.play()
	
	if is_dead or is_rolling:
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
		

	
	
	
	
