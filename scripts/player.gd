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

# Variable for zigzag motion of brute_force_attack
var last_movement = Vector2.UP

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $"../PlayerUI/HealthBar" # i think correct path
@onready var experience_bar = $"../PlayerUI/ExperienceBar"
@onready var experience_label = $"../PlayerUI/ExperienceLabel"
@onready var roll_sound_player: AudioStreamPlayer2D = $RollSoundPlayer
@onready var take_dmg_sound_player: AudioStreamPlayer2D = $TakeDamageSound

func _ready() -> void:
	add_to_group("player")
	facing_direction = Vector2.RIGHT
	attack()

# Nearby enemies
var enemies_in_range := []
var current_target : Node2D = null

func _physics_process(delta: float) -> void:
	if is_dead:
		return 
	
	enemies_in_range = $EnemyDetectionArea.get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		current_target = enemies_in_range.front()
	
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
		last_movement = input_vector
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
		

# Experience points
var experience := 0
var experience_level := 1
var collected_experience := 0
var accum = 0

# Experience collection logic
func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self
	
func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		calculate_experience(area.collect())

func calculate_experience(coin_exp: int) -> void:
	accum += coin_exp
	print(accum)
	collected_experience += coin_exp
	var experience_needed = calculate_experiencecap()
	
	while collected_experience > 0:
		experience_needed = calculate_experiencecap()
		if experience + collected_experience >= experience_needed: #level up!
			experience_level += 1
			print("level", experience_level)			
			if experience_label: # Update player level
				experience_label.level = experience_level
			collected_experience = experience + collected_experience - experience_needed
			experience = 0
		else:
			experience += collected_experience				
			collected_experience = 0
			
	if experience_bar: # Update exp bar
		experience_bar.max_value = experience_needed
		experience_bar.value = experience
	

func calculate_experiencecap() -> int:
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level - 19) * 10
	else:
		exp_cap = 255 + (experience_level - 39) * 20
	return exp_cap
	
func attack() -> void:
	if firewall_level > 0:
		FirewallReloadTimer.wait_time = firewall_attackspeed
		if FirewallReloadTimer.is_stopped():
			FirewallReloadTimer.start()

# Firewall Peppering
var firewall_ammo := 0
var firewall_base_ammo := 1
var firewall_attackspeed := 1.5
var firewall_level := 1
@onready var firewallPeppering = preload("res://scenes/attacks/firewall_peppering_attack.tscn")
@onready var FirewallReloadTimer = $Attacks/FirewallPeppering/FirewallReloadTimer
@onready var FirewallAttackTimer = $Attacks/FirewallPeppering/FirewallAttackTimer

func _on_firewall_reload_timer_timeout() -> void:
	firewall_ammo += firewall_base_ammo
	FirewallAttackTimer.start()

func _on_firewall_attack_timer_timeout() -> void:
	if firewall_ammo > 0:
		var firewall_attack = firewallPeppering.instantiate()
		firewall_attack.global_position = global_position
		firewall_attack.target = current_target.global_position if current_target and is_instance_valid(current_target) else Vector2.ZERO
		firewall_attack.level = firewall_level
		add_child(firewall_attack)
		firewall_ammo -= 1
		if firewall_ammo > 0:
			FirewallAttackTimer.start()
		else:
			FirewallAttackTimer.stop()
