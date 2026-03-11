class_name Player extends CharacterBody2D

const SPEED = 180.0
const MAX_HEALTH = 400
const ROLL_DURATION = 0.4
const ROLL_SPEED = 300.0
const ROLL_COOLDOWN = 1.0

var current_health = MAX_HEALTH
var armor = 0
var is_dead = false

var is_rolling = false
var roll_direction = Vector2.ZERO
var roll_timer = 0.0
var roll_cooldown_timer = 0.0

var facing_direction: Vector2 = Vector2.RIGHT

# Variable for zigzag motion of ddos_cyclone_attack
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
	else:
		current_target = null
	
	if current_target and is_instance_valid(current_target):
		GunNode.look_at(current_target.global_position)
		
	if gun_level > 0 and current_target and is_instance_valid(current_target):
		gun_timer -= delta
		if gun_timer <= 0:
			shoot(current_target)
			gun_timer = gun_fire_rate
	
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
	
	var before_normalize = Vector2(
		Input.get_action_strength("moveright") - Input.get_action_strength("moveleft"),
		Input.get_action_strength("movedown") - Input.get_action_strength("moveup")
	)
	
	var input_vector := before_normalize.normalized()
	
	if Input.is_action_just_pressed("roll") and roll_cooldown_timer <= 0:
		start_roll(input_vector)
		return
		
	if input_vector != Vector2.ZERO:
		last_movement = before_normalize
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
	current_health -= clamp(amount - armor, 1, 999)
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

var pending_level_ups = 0
var level_up_active = false

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
			pending_level_ups += 1
		else:
			experience += collected_experience
			collected_experience = 0
			
	if pending_level_ups > 0 and not level_up_active:
		level_up()
	
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

# Level Up Stuff
@onready var level_up_panel : Panel = $LevelUpCanvas/LevelUpPanel
@onready var level_up_label : RichTextLabel = $LevelUpCanvas/LevelUpPanel/LevelUpLabel
@onready var upgrade_options : VBoxContainer = $LevelUpCanvas/LevelUpPanel/UpgradeOptions
@onready var attack_option := preload("res://scenes/attack_option.tscn")
@onready var level_up_sound : AudioStreamPlayer2D = $LevelUpCanvas/LevelUpPanel/LevelUpSound

var upgrade_level_requirements := {
	"gun1": 8,
	"gun2": 14,
	"gun3": 21
}
var possible_upgrades = {}
var collected_upgrades = {}

func get_random_upgrade():
	var db = []
	for upgrade in UpgradesDatabase.upgrades:
		# skip if already collected or pending
		if collected_upgrades.has(upgrade):
			continue
		elif possible_upgrades.has(upgrade):
			continue
		elif UpgradesDatabase.upgrades[upgrade]["type"] == "item":
			continue
		
		# check prerequisites
		if UpgradesDatabase.upgrades[upgrade]["prerequisite"].size() > 0:
			var prereqs_met = true
			for prereq in UpgradesDatabase.upgrades[upgrade]["prerequisite"]:
				if not collected_upgrades.has(prereq):
					prereqs_met = false
					break
			if not prereqs_met:
				continue
		
		# check level requirement
		if upgrade_level_requirements.has(upgrade):
			if experience_level < upgrade_level_requirements[upgrade]:
				continue
		
		# if all conditions pass, allow upgrade
		db.append(upgrade)
	
	if db.size() > 0:
		var random_item = db.pick_random()
		possible_upgrades.set(random_item, true)
		return random_item
	else:
		return null
		
		
func upgrade_character(upgrade):
	match upgrade:
		"firewall1":
			firewall_level = 1
		"firewall2":
			firewall_level = 2
		"firewall3":
			firewall_level = 3
		"cyclone1":
			cyclone_level = 1
		"cyclone2":
			cyclone_level = 2
			cyclone_base_ammo += 1
		"cyclone3":
			cyclone_level = 3
			cyclone_base_ammo += 1
		"orbital1":
			orbital_level = 1
		"orbital2":
			orbital_level = 2
		"orbital3":
			orbital_level = 3
		"armor1", "armor2":
			armor += 1
		"armor3", "armor4":
			armor += 2
		"gun1":
			gun_level = 1
			gun_fire_rate = 0.30
			GunSprite.texture = load("res://assets/pistol/gun2.png")
			GunSprite.scale = Vector2(0.2, 0.2)
		"gun2":
			gun_level = 2
			gun_fire_rate = 0.20
			GunSprite.texture = load("res://assets/pistol/gun3.png")
			GunSprite.scale = Vector2(0.15, 0.15)
		"gun3":
			gun_level = 3
			gun_fire_rate = 0.05
			GunSprite.texture = load("res://assets/pistol/gun4.png")
			GunSprite.scale = Vector2(0.13, 0.13)
		"food":
			current_health += 60
			clamp(current_health, 0, MAX_HEALTH)
			update_health_bar()
			
	var upgrade_children = upgrade_options.get_children()
	for child in upgrade_children:
		child.queue_free()
	possible_upgrades.clear()
	collected_upgrades.set(upgrade, true)
	level_up_panel.visible = false
	level_up_panel.position = Vector2(1236, 77)
	get_tree().paused = false
	
	pending_level_ups -= 1
	if pending_level_ups > 0:
		level_up()
	else:
		level_up_active = false
		attack()

func level_up() -> void:
	level_up_active = true
	level_up_sound.play()
	var tween := level_up_panel.create_tween()
	tween.tween_property(level_up_panel, "position", Vector2(319, 76), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	level_up_panel.visible = true
	
	var options = 0
	var max_options = 3
	while options < max_options:
		var new_option = attack_option.instantiate()
		new_option.item = get_random_upgrade()
		upgrade_options.add_child(new_option)
		options += 1
		
	get_tree().paused = true

# Attacks
func attack() -> void:
	if firewall_level > 0:
		FirewallReloadTimer.wait_time = firewall_attackspeed
		if FirewallReloadTimer.is_stopped():
			FirewallReloadTimer.start()
	if cyclone_level > 0:
		CycloneReloadTimer.wait_time = cyclone_attackspeed
		if CycloneReloadTimer.is_stopped():
			CycloneReloadTimer.start()
	if orbital_level > 0:
		while (num_of_swords < orbital_level):
			num_of_swords += 1
			$Attacks/ArtemisOrbital.add_child(sword.instantiate())

# Artemis Orbital
var orbit_speed := 2.0
var num_of_swords := 0
var orbital_level := 0
@onready var sword = preload("res://scenes/attacks/sword.tscn")

# DDOS Cyclone
var cyclone_ammo := 0
var cyclone_base_ammo := 2
var cyclone_attackspeed := 3.0
var cyclone_level := 0
@onready var DDOSCyclone = preload("res://scenes/attacks/ddos_cyclone.tscn")
@onready var CycloneReloadTimer = $Attacks/DDOSCyclone/CycloneReloadTimer
@onready var CycloneAttackTimer = $Attacks/DDOSCyclone/CycloneAttackTimer

func _on_cyclone_reload_timer_timeout() -> void:
	cyclone_ammo += cyclone_base_ammo
	CycloneAttackTimer.start()

func _on_cyclone_attack_timer_timeout() -> void:
	if cyclone_ammo > 0:
		var cyclone_attack = DDOSCyclone.instantiate()
		cyclone_attack.global_position = global_position
		cyclone_attack.last_movement = last_movement
		cyclone_attack.level = cyclone_level
		add_child(cyclone_attack)
		cyclone_ammo -= 1
		if cyclone_ammo > 0:
			CycloneAttackTimer.start()
		else:
			CycloneAttackTimer.stop()

# Firewall Peppering
var firewall_ammo := 0
var firewall_base_ammo := 1
var firewall_attackspeed := 1.5
var firewall_level := 0
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
			
var gun_level := 1
var gun_fire_rate := 0.5  # seconds per shot
var gun_timer := 0.0      # counts down for shooting

@onready var GunNode = $Attacks/Gun
@onready var ShootingPoint = $Attacks/Gun/WeaponPivot/PistolBasic/ShootingPoint
@onready var ShootSFX = $Attacks/Gun/ShootSFX
@onready var GunSprite: Sprite2D = $Attacks/Gun/WeaponPivot/PistolBasic
const BULLET = preload("res://scenes/bullet.tscn")

func shoot(target: Node2D) -> void:
	var new_bullet = BULLET.instantiate()
	$Attacks.add_child(new_bullet)  # ensures bullet is visible
	new_bullet.global_position = ShootingPoint.global_position
	new_bullet.look_at(target.global_position)
	new_bullet.direction = Vector2.RIGHT.rotated(new_bullet.rotation)
	ShootSFX.play()
