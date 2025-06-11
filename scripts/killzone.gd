class_name killzone extends Area2D

@onready var timer: Timer = $Timer
@export var damage = 20

func _on_body_entered(body: Node2D) -> void:
	print("Entered:", body.name)
	if body is Player:
		var player: Player = body
		if not player.is_dead:
			player.take_damage(damage)
	

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0	
	get_tree().reload_current_scene()
