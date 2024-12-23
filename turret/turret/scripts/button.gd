extends Button


func _process(delta: float) -> void:
	if get_parent().get_node("cannon").health < 0:
		get_parent().get_child(0).get_child(6).play()
		get_tree().paused = true
		self.visible = true
		get_parent().get_node("UI").visible = false

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_parent().get_node("Spawner").reset_game()
	self.visible = false
	get_parent().get_node("UI").visible = true
	get_parent().coins = 0
	get_parent().get_node("UI").reset()
	get_parent().get_node("cannon").maxHealth = 200
	await get_tree().create_timer(1).timeout
	get_parent().get_node("cannon").health = 200
