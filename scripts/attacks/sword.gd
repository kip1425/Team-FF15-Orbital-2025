extends Area2D

var damage := 0.7
var already_hit := {}
var weapon_manager

func _ready() -> void:
	weapon_manager = get_parent().get_parent()
	if weapon_manager.has_signal("orbit_end"):
		weapon_manager.connect("orbit_end", Callable(self, "_on_orbit_end"))

func _on_orbit_end() -> void:
	already_hit.clear()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var id := str(body.get_instance_id())
		if already_hit.has(id):
			return
		body.take_damage(damage)
		already_hit[id] = true
