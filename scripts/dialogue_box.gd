extends TextureRect

@onready var name_label = $NameLabel
@onready var dialogue_text = $DialogueText

var dialogue_lines: Array = []
var current_line_index := 0

var full_text := ""
var char_index := 0
var typing := false
var typing_speed := 0.02
var type_timer = 0.0

var finished_callback: Callable = Callable()

func _ready():
	self.visible = false
	
func start_dialogue(lines: Array, callback: Callable = Callable()):
	dialogue_lines = lines
	current_line_index = 0
	finished_callback = callback
	self.visible = true
	_show_next_line()

func _process(delta: float) -> void:
	if typing:
		type_timer += delta
		if type_timer >= typing_speed:
			type_timer = 0.0
			if char_index < full_text.length():
				char_index += 1
				dialogue_text.text = full_text.substr(0, char_index)
			else:
				typing = false
				
func _input(event):
	if not visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		#"ui_accept" is an inbuilt keybind btw
		if typing:
			dialogue_text.text = full_text
			typing = false
		else:
			_show_next_line()
		
func _show_next_line():
	if current_line_index >= dialogue_lines.size():
		_end_dialogue()
		return
	
	var line_data = dialogue_lines[current_line_index]
	if typeof(line_data) == TYPE_DICTIONARY:
		name_label.text = line_data.get("speaker", "")
		full_text = line_data.get("text", "")
	else:
		full_text = str(line_data)
		name_label.text = ""
	
	char_index = 0
	dialogue_text.text = ""
	typing = true
	type_timer = 0.0
	current_line_index += 1
	
func _end_dialogue():
	self.visible = false
	if finished_callback.is_valid():
		finished_callback.call()

# Called every frame. 'delta' is the elapsed time since the previous frame.
