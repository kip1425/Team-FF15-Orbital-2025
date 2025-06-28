extends Node2D

var ENEMY_NUMBER = 4

func _ready() -> void:
	spawn_mob()
	spawn_mob()
	spawn_mob()
	spawn_mob()
	spawn_mob()
	
	
@onready var pause_menu = $Player/Camera2D/PauseMenu
@onready var path_follow = $Path2D/PathFollow2D
var paused = false

func spawn_random_mob():
	var rand = randi() % 4
	match rand:
		0: spawn_mob()
		1: spawn_ranged_mob()
		2: spawn_exploder_mob()
		3: spawn_splitter_mob()

# Called when the node enters the scene tree for the first time.
func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
	spawn_at_path(new_mob)
	
func spawn_ranged_mob():
	var new_mob = preload("res://scenes/ranged_mob.tscn").instantiate()
	spawn_at_path(new_mob)
	
func spawn_exploder_mob():
	var new_mob = preload("res://scenes/exploder.tscn").instantiate()
	spawn_at_path(new_mob)
	
func spawn_splitter_mob():
	var new_mob = preload("res://scenes/splitter_mob.tscn").instantiate()
	spawn_at_path(new_mob)
	
func spawn_at_path(mob):
	path_follow.progress_ratio = randf()
	mob.global_position = path_follow.global_position
	add_child(mob)

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
