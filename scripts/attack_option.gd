extends ColorRect

var mouse_over := false
var item = null
@onready var player = get_tree().get_first_node_in_group("player")
@onready var name_label = $Name
@onready var level_label = $Level
@onready var description_label = $Description
@onready var item_icon = $TextureRect/ItemIcon

signal selected_upgrade(upgrade)

func _ready() -> void:
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	if item == null:
		item = "food"
	name_label.text = UpgradesDatabase.upgrades[item]["name"]
	level_label.text = UpgradesDatabase.upgrades[item]["level"]
	description_label.text = UpgradesDatabase.upgrades[item]["description"]
	item_icon.texture = load(UpgradesDatabase.upgrades[item]["icon"])
	
func _input(action) -> void:
	if action.is_action("click"):
		if mouse_over:
			emit_signal("selected_upgrade", item)

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
