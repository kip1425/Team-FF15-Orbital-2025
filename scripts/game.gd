extends Node2D

var ENEMY_NUMBER = 4

func _ready() -> void:
	spawn_boss_mob()
	
@onready var pause_menu = $Player/Camera2D/PauseMenu
@onready var path_follow = $Path2D/PathFollow2D
@onready var center_marker = $BossSpawn
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

func spawn_boss_mob():
	var new_boss = preload("res://scenes/boss.tscn").instantiate()
	var player_ui = get_node_or_null("/root/Game/PlayerUI")
	new_boss.global_position = center_marker.global_position

	if player_ui:
		new_boss.connect("health_changed", Callable(player_ui, "_on_boss_health_changed"))
		new_boss.connect("died", Callable(player_ui, "_on_boss_died"))
		player_ui.show_boss_bar("Eldon, the Cruel", new_boss.max_health)

	add_child(new_boss)
	
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
