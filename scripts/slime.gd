extends Node2D

const SPEED = 60
var direction = 1
@onready var raycastright: RayCast2D = $raycastright
@onready var raycastleft: RayCast2D = $raycastleft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# select, drag and drop while holding control ^

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if raycastright.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
	if raycastleft.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
	position.x += SPEED * delta * direction
	
