extends Control
@onready var label = $TypewriterLabel
@onready var bgm = $AudioStreamPlayer 

var full_texts = [ "Thank you for playing our game! This has been a great experience for our small but highly motivated team of two Computer Science majors",

"We hope you had as much fun playing as we did coding >_<",

"(Almost) all assets used are open-source and royalty free, so credits to the respective owners (im too lazy to list all of them)", 

"Thank you for playing our Orbital 2025 project! - Shu Xian & Sern Yuan"
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
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
