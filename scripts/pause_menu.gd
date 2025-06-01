extends Control

@onready var main = $"../../../"

func _on_pause_quit_pressed() -> void:
	get_tree().quit()

func _on_pause_resume_pressed() -> void:
	main.pauseMenu() # Replace with function body.
