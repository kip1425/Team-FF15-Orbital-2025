extends Node2D

@export var orbit_radius: float = 30.0
@export var orbit_speed: float = 5.0

var angle_offset := 0.0
var last_reset_angle := 0.0
signal orbit_end

func _process(delta: float) -> void:
	angle_offset += orbit_speed * delta
	angle_offset = fmod(angle_offset, TAU)

	if last_reset_angle > angle_offset:
		emit_signal("orbit_end")
	last_reset_angle = angle_offset
	
	var sword_count = get_child_count()
	for i in range(sword_count):
		var sword = get_child(i)
		var angle = angle_offset + (TAU / sword_count) * i
		var offset = Vector2.RIGHT.rotated(angle) * orbit_radius
		sword.global_position = global_position + offset
		sword.rotation = angle + PI / 2
