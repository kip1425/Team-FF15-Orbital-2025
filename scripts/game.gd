extends Node2D

var ENEMY_NUMBER = 4

func _ready() -> void:
	spawn_exploder_mob()
	spawn_exploder_mob()
	spawn_exploder_mob()
	spawn_splitter_mob()
	spawn_splitter_mob()
	for i in range(ENEMY_NUMBER):
		spawn_mob()
		spawn_mob()
		spawn_ranged_mob()
	
@onready var pause_menu = $Player/Camera2D/PauseMenu
var paused = false

# Called when the node enters the scene tree for the first time.
func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	
func spawn_ranged_mob():
	var new_mob = preload("res://scenes/ranged_mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	
func spawn_exploder_mob():
	var new_mob = preload("res://scenes/exploder.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	
func spawn_splitter_mob():
	var new_mob = preload("res://scenes/splitter_mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused
