extends Area2D

const SPEED = 200
const RANGE = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var travelled_distance = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 2d vector with constant RIGHT
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	travelled_distance += SPEED * delta 
	if travelled_distance > RANGE:
		queue_free() # destroy object
	
# signal connected to this function	
func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
