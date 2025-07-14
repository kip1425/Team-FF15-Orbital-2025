extends CharacterBody2D
class_name Boss

enum STATE {
	IDLE,
	CHASE, 
	SPECIAL,
	SPIRAL,
	RUSH_PREP,
	RUSH_MOVE,
	RUSH_RECOVER,
	DIE
}

var current_state = STATE.IDLE
var max_health = 300
var health: int = max_health
var is_dead = false

const SPEED = 80.0
const RUSH_SPEED = 500.0
const RUSH_DURATION = 0.6
const RUSH_CLOSE_DIST = 24.0
const SPIRAL_INTERVAL = 0.08
const SPIRAL_TOTAL_SHOTS = 60
const SPIRAL_ANGLE_STEP = TAU / 12
const DIG_UP_ENABLE_FRAME = 10
const UNBURROW_DELAY = 0.8

var spiral_elapsed = 0.0
var spiral_angle = 0.0
var spiral_shots_fired = 0

var special_fired = false
var rush_dir = Vector2.ZERO
var rush_timer = 0.0

@onready var anim = $AnimatedSprite2D
@onready var player = get_node("/root/Game/Player")
@onready var state_timer = $StateTimer
@onready var shoot_point = $ShootPoint
@onready var body_shape = $CollisionShape2D

@onready var projectile_scene = preload("res://scenes/boss_projectile.tscn")
@onready var spiral_projectile_scene = preload("res://scenes/boss_projectile.tscn")

func _ready():
	randomize()

func _physics_process(delta: float) -> void:
	if is_instance_valid(player) and current_state not in [STATE.RUSH_PREP, STATE.RUSH_MOVE]:
		anim.flip_h = player.global_position.x > global_position.x
	
	match current_state:
		STATE.IDLE:
			handle_idle(delta)
		STATE.CHASE:
			handle_chase(delta)
		STATE.SPECIAL:
			handle_attack(delta)
		STATE.SPIRAL:
			handle_spiral(delta)
		STATE.RUSH_PREP:
			pass
		STATE.RUSH_MOVE:
			handle_rush_move(delta)
		STATE.RUSH_RECOVER:
			pass
		STATE.DIE:
			handle_die(delta)
				
func _set_collision_enabled(enabled: bool) -> void:
	body_shape.set_deferred("disabled", not enabled)
		
func handle_idle(delta):
	velocity = Vector2.ZERO
	if state_timer.is_stopped():
		state_timer.start(1.5)
	
func handle_chase(delta):
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		return
	var dir = global_position.direction_to(player.global_position)
	velocity = dir * SPEED
	move_and_slide()
	if global_position.distance_to(player.global_position) < 120:
		_pick_close_range_attack()

func handle_attack(delta):
	pass
	
func handle_die(delta):
	velocity = Vector2.ZERO
	
func handle_spiral(delta):
	spiral_elapsed += delta
	if spiral_elapsed >= SPIRAL_INTERVAL:
		spiral_elapsed -= SPIRAL_INTERVAL
		fire_spiral_projectile()
		spiral_shots_fired += 1
		if spiral_shots_fired >= SPIRAL_TOTAL_SHOTS:
			change_state(STATE.IDLE)

func handle_rush_move(delta: float) -> void:
	rush_timer += delta
	if not is_instance_valid(player):
		change_state(STATE.RUSH_RECOVER)
		return
	
	rush_dir = global_position.direction_to(player.global_position).normalized()
	velocity = rush_dir * RUSH_SPEED
	move_and_slide()
	
	if global_position.distance_to(player.global_position) <= RUSH_CLOSE_DIST or rush_timer >= RUSH_DURATION:
		change_state(STATE.RUSH_RECOVER)

func change_state(new_state):
	if current_state == new_state:
		return
	
	current_state = new_state
	state_timer.stop()
	
	match current_state:
		STATE.IDLE:
			velocity = Vector2.ZERO 
			anim.play("idle")
			state_timer.start(1.5)
		STATE.CHASE:
			anim.play("chase")
			state_timer.start(3.0)
		STATE.SPECIAL:
			velocity = Vector2.ZERO 
			anim.play("sp_atk")
			special_fired = false
		STATE.SPIRAL:
			velocity = Vector2.ZERO 
			anim.play("sp_atk")
			spiral_elapsed = 0.0
			spiral_angle = 0.0
			spiral_shots_fired = 0
		STATE.RUSH_PREP:
			_set_collision_enabled(false)
			anim.play("dig_down")
			rush_timer = 0.0
			await anim.animation_finished
			if is_instance_valid(player):
				rush_dir = global_position.direction_to(player.global_position).normalized()
			else:
				rush_dir = Vector2.RIGHT
			change_state(STATE.RUSH_MOVE)
		STATE.RUSH_MOVE:
			rush_timer = 0.0
			anim.visible = false
		STATE.RUSH_RECOVER:
			velocity = Vector2.ZERO
			await get_tree().create_timer(UNBURROW_DELAY).timeout
			
			anim.visible = true
			anim.play("dig_up")
			await anim.animation_finished
			change_state(STATE.IDLE)
		STATE.DIE:
			velocity = Vector2.ZERO 
			anim.play("death")
			
func fire_projectile_burst(count: int = 16, trail_count: int = 3, trail_spacing: float = 14.0):
	for i in range(count):
		var angle = i * TAU / count  # TAU = 2π
		var dir = Vector2.RIGHT.rotated(angle)
		
		for t in range(trail_count):
			var projectile = projectile_scene.instantiate()
			
			projectile.global_position = shoot_point.global_position - dir * trail_spacing * t
			projectile.init(dir)
			
			var fade = 1.0 - float(t) / max(1, trail_count)
			projectile.self_modulate.a = fade
			
			get_parent().add_child(projectile)
			
func fire_spiral_projectile():
	var dir = Vector2.RIGHT.rotated(spiral_angle)
	spiral_angle += SPIRAL_ANGLE_STEP
	var p = spiral_projectile_scene.instantiate()
	p.global_position = shoot_point.global_position
	p.init(dir)
	get_parent().add_child(p)

signal health_changed(current: int, max: int)
signal died

func take_damage(damage: int) -> void:
	if is_dead:
		return
	health -= damage
	emit_signal("health_changed", health, max_health)
	if health <= 0:
		is_dead = true
		emit_signal("died")
		change_state(STATE.DIE)  

func _on_state_timer_timeout() -> void:
	match current_state:
		STATE.IDLE:
			change_state(STATE.CHASE)
		STATE.CHASE:
			_pick_close_range_attack()
			
func _pick_close_range_attack() -> void:
	var roll = randi() % 3
	if roll == 0:
		change_state(STATE.SPECIAL)
	elif roll == 1:
		change_state(STATE.SPIRAL)
	else:
		change_state(STATE.RUSH_PREP)
		
func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == STATE.SPECIAL:
		change_state(STATE.IDLE)
	elif current_state == STATE.DIE:
		queue_free()

func _on_animated_sprite_2d_frame_changed() -> void:
	if current_state == STATE.SPECIAL and anim.frame == 5 and not special_fired:
		fire_projectile_burst()
		special_fired = true
	
	elif current_state == STATE.RUSH_RECOVER and anim.animation == "dig_up" and anim.frame == DIG_UP_ENABLE_FRAME:
		_set_collision_enabled(true)
