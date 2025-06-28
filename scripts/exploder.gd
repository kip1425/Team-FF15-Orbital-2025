extends "res://scripts/mob.gd"

@export var wind_up_time: float = 1.5
@export var explosion_damage: int = 25
@export var explosion_radius: float = 64.0

@onready var explosion_area = $ExplosionArea
@onready var wind_up_timer = $WindUpTimer
@onready var flash_timer = $FlashTimer
@onready var explode_timer = $ExplodeTimer
@onready var sprite = $exploder_animation

var is_winding_up = false

func _ready():
	SPEED = 180
	explosion_area.monitoring = false
	sprite.modulate = Color(1, 1, 1)
	super._ready()
	
func _physics_process(delta):
	if is_winding_up or not is_instance_valid(player):
		move_and_slide()
		return
	if is_winding_up:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED 
	
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
		
	move_and_slide()
	
	if global_position.distance_to(player.global_position) < explosion_radius:
		start_wind_up()

func start_wind_up():
	if is_winding_up:
		return
	is_winding_up = true
	velocity = Vector2.ZERO
	wind_up_timer.start(wind_up_time)
	flash_timer.start(0.1)
	
func explode():
	sprite.play("explode")
	explosion_area.monitoring = true
	explode_timer.start(0.2)

func _on_explosion_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(explosion_damage)

func _on_wind_up_timer_timeout() -> void:
	explode() # Replace with function body.

func _on_flash_timer_timeout() -> void:
	sprite.modulate = Color(1, 0, 0) if sprite.modulate == Color(1, 1, 1) else Color(1, 1, 1)
	if is_winding_up:
		flash_timer.start(0.1)

func _on_explode_timer_timeout() -> void:
	die() # Replace with function body.

func die():
	queue_free()
	
