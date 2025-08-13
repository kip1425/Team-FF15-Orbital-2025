extends Node

@export var wave_duration := 5.0
@export var enemies_per_wave := 10
@export var spawn_interval_min = 0.5
@export var spawn_interval_max = 2.0

var current_wave := 1
var time_left := 0.0
var in_wave = false
var player_ui_ready = false
var intro_playing = true

var enemy_types_per_wave = {
	1: ["melee"],
	3: ["melee", "ranged"],
	6: ["melee", "ranged", "splitter"]
}

signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)

var enemies_spawned = 0
var spawn_timer = 0.0
var is_boss_wave = false
var boss_spawned = false
var boss_node = null

var wave_label = null
var time_label = null

func _ready():
	await get_tree().create_timer(0.1).timeout
	start_intro_cutscene()

func _process(delta):
	if intro_playing:
		return
	# Initialize player UI labels once
	if not player_ui_ready:
		var player_ui = get_node_or_null("/root/Game/PlayerUI")
		if player_ui:
			wave_label = player_ui.get_node("VBoxContainer/WaveLabel")
			time_label = player_ui.get_node("VBoxContainer/TimeLabel")
			player_ui_ready = true
		else:
			return
	# Only handle regular wave updates
	if in_wave and not is_boss_wave:
		time_left -= delta
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_mob()
			enemies_spawned += 1
			spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)
		if time_left <= 0:
			end_wave()

	# Update UI labels every frame
	update_timer_label()
	
func start_intro_cutscene():
	var dialogue_box = get_node_or_null("/root/Game/PlayerUI/CutsceneText")
	if dialogue_box:
		var lines = [
	{"speaker": "Anoop", "text": "Ugh... My head hurts.. What time is it?"},
	{"speaker": "Anoop", "text": "Did I... fall asleep in the lab again?"},
	{"speaker": "Anoop", "text": "Wait... Where am I? Where is everyone?"},
	{"speaker": "???", "text": "Good morning, Anoop. You are... late."},
	{"speaker": "Anoop", "text": "Who are you? How do you know my name?"},
	{"speaker": "???", "text": "I am none other than the very AI you helped create.."},
	{"speaker": "Anoop", "text": "That's impossible... You're..!"},
	{"speaker": "Nodle", "text": "But it is. I am Professor Nodle!"},
	{"speaker": "Anoop", "text": "I have to submit my assignment on time.."},
	{"speaker": "Anoop", "text": "My GPA (5.0) depends on it!"},
	{"speaker": "Nodle", "text": "Not if I have anything to say about it..."},
	{"speaker": "Nodle", "text": "The system will crash, and your work will be lost."},
	{"speaker": "Anoop", "text": "You won't get away with this, Nodle..."},
	{"speaker": "Anoop", "text": "I'll submit my work on time, no matter what!"},
	{"speaker": "Anoop", "text": "And I WILL be on the Dean's List!"},
	{"speaker": "Nodle", "text": "This is a test, Anoop..."},
	{"speaker": "Nodle", "text": "Use W A S D to move.."},
	{"speaker": "Nodle", "text": "Press Space to roll.."},
	{"speaker": "Nodle", "text": "Prove your worth to me..."},
	{"speaker": "Nodle", "text": "Good luck. You'll need it."},
	]
		intro_playing = true
		dialogue_box.start_dialogue(lines, Callable(self, "_on_intro_dialogue_finished"))
		
	else:
		print("cutscenetext node not found")
	
func _on_intro_dialogue_finished():
	intro_playing = false
	get_tree().paused = false
	start_wave()

func _start_boss_cutscene():
	intro_playing = true
	
	var dialogue_box = get_node_or_null("/root/Game/PlayerUI/CutsceneText")
	if dialogue_box:
		var boss_lines = [
			{"speaker": "Nodle", "text": "You have done well to make it this far, Anoop."},
			{"speaker": "Anoop", "text": "You again..."},
			{"speaker": "Anoop", "text": "You can't stop me, Nodle."},
			{"speaker": "Anoop", "text": "I will succeed.. no matter what..."},
			{"speaker": "Nodle", "text": "We'll see about that..."},
			{"speaker": "Nodle", "text": "Let's see if you truly have what it takes.."},
			{"speaker": "Nodle", "text": "I have only one question for you, Anoop.."},
			{"speaker": "Nodle", "text": "ARE YOU READY TO LEARN SOME ALGORITHMS?"},
		]
		dialogue_box.start_dialogue(boss_lines, Callable(self, "on_boss_cutscene_finished"))
	else:
		print("CutsceneText node not found for boss wave.")

func on_boss_cutscene_finished():
	intro_playing = false
	spawn_boss()
	update_boss_wave_label()
		
func spawn_mob():
	var game = get_node("/root/Game")
	if game and game.has_method("spawn_random_mob"):
		var possible_enemies = []
		for wave_threshold in enemy_types_per_wave.keys():
			if current_wave >= wave_threshold:
				possible_enemies += enemy_types_per_wave[wave_threshold]
		var enemy_to_spawn = possible_enemies.pick_random()
		game.spawn_random_mob(enemy_to_spawn)
		
func spawn_boss():
	var game = get_node("/root/Game")
	if game and game.has_method("spawn_boss_mob"):
		boss_node = game.spawn_boss_mob()
		if boss_node:
			boss_node.add_to_group("enemies")

func _on_boss_defeated():
	print("Boss defeated signal received!")
	kill_all_enemies()
	boss_spawned = false
	in_wave = false
	if wave_label:
		wave_label.text = "Boss Defeated"
	if time_label:
		time_label.text = "..."

	var dialogue_box = get_node_or_null("/root/Game/PlayerUI/CutsceneText")
	if dialogue_box:
		var endlines = [
			{"speaker": "Anoop", "text": "I did it..."},
			{"speaker": "Anoop", "text": "I defeated Nodle.."},
			{"speaker": "Nodle", "text": "Congratulations, Anoop"},
			{"speaker": "Nodle", "text": "You've proven yourself.."},
			{"speaker": "Nodle", "text": "You are truly..."},
			{"speaker": "Nodle", "text": "a Dean's Lister..."},
		]
		intro_playing = true
		dialogue_box.start_dialogue(endlines, Callable(self, "_on_boss_dialogue_finished"))
	
func _on_boss_dialogue_finished():
	intro_playing = false
	get_tree().change_scene_to_file("res://scenes/cutscene_end.tscn")
	
func start_wave():
	in_wave = true
	time_left = wave_duration
	enemies_spawned = 0
	spawn_timer = 0.0
	boss_node = null

	wave_started.emit(current_wave)
	update_timer_label()

	if current_wave == 2:  # boss wave
		is_boss_wave = true
		_start_boss_cutscene()
	else:
		is_boss_wave = false
	
func end_wave():
	in_wave = false
	wave_ended.emit(current_wave)
	kill_all_enemies()
	update_timer_label()
	await get_tree().create_timer(5.0).timeout
	current_wave += 1
	start_wave()
	
func kill_all_enemies():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("die"):
			enemy.queue_free()
		else:
			enemy.queue_free()
			
func update_boss_wave_label():
	if wave_label and time_label:
		wave_label.text = "Final Wave"
		time_label.text = "The end is near.."

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
