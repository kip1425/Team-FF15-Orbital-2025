extends Area2D

var enemies_in_range: Array = []

func _ready():
	monitoring = true  # should be true under inspector alr
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Timer.start()

func _physics_process(delta):
	enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)

func _on_timer_timeout():
	if enemies_in_range.size() > 0:
		shoot()
		$ShootSFX.play()

func shoot():
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()

	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_bullet)
