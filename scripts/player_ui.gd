extends CanvasLayer  

func show_boss_bar(name: String, max_health: int):
	$BossHealthBar/BossNameLabel.text = name
	$BossHealthBar.max_value = max_health
	$BossHealthBar.value = max_health
	$BossHealthBar.show()

func _on_boss_health_changed(current: int, max: int) -> void:
	$BossHealthBar.max_value = max
	$BossHealthBar.value = current

func _on_boss_died() -> void:
	$BossHealthBar.hide()
