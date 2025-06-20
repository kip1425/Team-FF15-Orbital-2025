extends "res://scripts/mob.gd"

@export var shoot_cooldown: float = 1.2
@export var shoot_range: float = 10.0
@onready var shoot_timer = $Shoot_Timer
@onready var bullet_scene = preload("res://scenes/enemy_projectile.tscn")

const speed = 40.0

func _ready():
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.timeout.connect(_on_timer_timeout)
	shoot_timer.start()

func _physics_process(delta: float) -> void:
	if is_hurt:
		move_and_slide()
		return
		
	var distance = global_position.distance_to(player.global_position)
	if distance > shoot_range:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		
		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0

	else: 
		velocity = Vector2.ZERO
		if player: 
			animated_sprite.flip_h = (player.global_position.x < global_position.x)
		
	move_and_slide()

func _on_timer_timeout() -> void:
	if not player or is_hurt:
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position	
	var dir = player.global_position - global_position
	bullet.init(dir)
	get_tree().current_scene.add_child(bullet)
	
