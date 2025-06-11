extends Node2D

var ENEMY_NUMBER = 6

func _ready() -> void:
	for i in range(ENEMY_NUMBER):
		spawn_mob()	
	
@onready var pause_menu = $Player/Camera2D/PauseMenu
var paused = false

# Called when the node enters the scene tree for the first time.
func spawn_mob():
	var new_mob = preload("res://scenes/mob.tscn").instantiate()
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
