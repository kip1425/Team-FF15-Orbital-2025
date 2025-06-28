extends Node

@export var wave_duration := 30.0
@export var enemies_per_wave := 10
@export var spawn_interval_min = 0.5
@export var spawn_interval_max = 2.0

var current_wave := 1
var time_left := 0.0
var in_wave = false
var player_ui_ready = false

signal wave_started(wave_number: int) 
signal wave_ended(wave_number: int)

var enemies_spawned = 0
var spawn_timer = 0.0

var wave_label = null
var time_label = null

func _ready():
	await get_tree().create_timer(0.1).timeout
	start_wave()
	
func _process(delta):
	if not player_ui_ready:
		var player_ui = get_node_or_null("/root/Game/PlayerUI")
		if player_ui:
			wave_label = player_ui.get_node("VBoxContainer/WaveLabel")
			time_label = player_ui.get_node("VBoxContainer/TimeLabel")
			player_ui_ready = true
		else:
			return
	
	if in_wave:
		time_left -= delta
		spawn_timer -= delta
		
		if spawn_timer <= 0 and enemies_spawned < enemies_per_wave:
			spawn_mob()
			enemies_spawned += 1
			spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)
		
		update_timer_label()
		
		if time_left <= 0:
			end_wave()
			
func spawn_mob():
	var game = get_node("/root/Game")
	if game and game.has_method("spawn_random_mob"):
		game.spawn_random_mob()
	else:
		print("Game node or spawn_random_mob() not found!")
	
func start_wave():
	in_wave = true
	time_left = wave_duration
	enemies_spawned = 0
	spawn_timer = 0.0
	wave_started.emit(current_wave)
	print("Wave %d started" % current_wave)
	update_timer_label()
	
func end_wave():
	in_wave = false
	wave_ended.emit(current_wave)
	print("Wave %d ended" % current_wave)
	kill_all_enemies()
	update_timer_label()
	await get_tree().create_timer(5.0).timeout
	current_wave += 1
	start_wave()
	
func kill_all_enemies():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("die"):
			enemy.die()
		else:
			enemy.queue_free()

func update_timer_label():
	if wave_label and time_label:
		if in_wave:
			wave_label.text = "Wave %d" % current_wave
			time_label.text = "%d" % max(0, ceil(time_left))
		else:
			wave_label.text = "Wave %d Complete" % current_wave
			time_label.text = "Next wave starting.."
	else:
		print("Labels not found!")
