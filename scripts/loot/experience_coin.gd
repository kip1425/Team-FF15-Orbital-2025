extends Area2D

@export var experience : int = 15

var gold_coin = preload("res://assets/loot/gold_coin.tres")
var silver_coin = preload("res://assets/loot/silver_coin.tres")
var red_coin = preload("res://assets/loot/red_coin.tres")

var speed : float = 0

func _ready() -> void:
	if experience <= 5:
		$AnimatedSprite2D.play("default")
	elif experience <= 25:
		$AnimatedSprite2D.sprite_frames = gold_coin
		$AnimatedSprite2D.play("default")
	elif experience <= 50:
		$AnimatedSprite2D.sprite_frames = red_coin
		$AnimatedSprite2D.play("default")

func collect() -> int:
	return experience
	
func _on_sound_finished() -> void:
	queue_free()

var target : Node2D = null

func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta
		
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("collect_area"):
		$AnimationPlayer.play("pickup")
		$Sound.play()
