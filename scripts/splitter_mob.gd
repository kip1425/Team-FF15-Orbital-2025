extends "res://scripts/mob.gd"

@export var spawn_mobs: Array[PackedScene] = [
	preload("res://scenes/mob.tscn"),
	preload("res://scenes/ranged_mob.tscn")
]
func _ready():
	health = 8
# overrides die from parent class mob btw
func die():
	print("splitter died")
	var spawn_count = randi_range(2, 4)
	
	for i in range(spawn_count):
		if spawn_mobs.is_empty():
			break
		
		var scene = spawn_mobs[randi() % spawn_mobs.size()]
		var child = scene.instantiate()
		child.global_position = global_position + Vector2(randf() * 20 - 10, randf() * 20 - 10)
		get_tree().current_scene.add_child(child)
		
	queue_free()
