extends Control
@onready var label = $TypewriterLabel
@onready var bgm = $AudioStreamPlayer 

var full_texts = [ "The year is 2040. The cutting-edge Noose University stands at the forefront of Artificial Intelligence research.",

"Among its brightest students was Anoop, a sleep-deprived but brilliant Computer Science major, who, along with his classmates, contributed to creating an advanced AI system.",

"But something went horribly wrong.",

"The AI they developed began to evolve beyond their control, twisting into a corrupted force that infected the very students who  built it — turning them into relentless coding zombies.",

"Now, with the campus overrun by the digital plague they unwittingly unleashed, Anoop must confront the chaos spawned from his own creation.",

"Armed with only his wits, makeshift weapons, and deep knowledge of Computer Science, he must fight through wave after wave of corrupted classmates, face the rogue AI professor controlling the madness, and race against time to submit his final project before the deadline.", 

"This... is his story."
]

var current_index = 0
var char_index = 0
var typing_speed = 0.03
var type_timer = 0.0
var typing = false
var full_text = ""

func _ready() -> void:
	label.text = ""
	_next_line()
	if bgm:
		bgm.play()

func _input(event):
	if event.is_action_pressed("ui_accept") or event is InputEventMouseButton and event.pressed:
		if typing:
			label.text = full_text
			typing = false
		else:
			_next_line()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		if typing:
			type_timer += delta
		if type_timer >= typing_speed:
			type_timer = 0.0
			char_index += 1
			if char_index <= full_text.length():
				label.text = full_text.substr(0, char_index)
			else:
				typing = false

func _next_line():
	if current_index >= full_texts.size():
		_transition_to_game()
		return
	full_text = full_texts[current_index]
	current_index += 1
	char_index = 0
	label.text = ""
	typing = true
	type_timer = 0.0
	
func _transition_to_game():
	# Replace this with your actual game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	
