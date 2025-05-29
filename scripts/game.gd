extends Node2D

func _ready() -> void:
	spawn_mob()
	spawn_mob()
	spawn_mob()
	spawn_mob()
	spawn_mob()

# Called when the node enters the scene tree for the first time.
func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
