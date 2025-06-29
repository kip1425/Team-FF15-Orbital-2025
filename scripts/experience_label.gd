extends Label

@export var player: Player

# Called when the node enters the scene tree for the first time.
var level := 1

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		text = "Level " + str(level)
