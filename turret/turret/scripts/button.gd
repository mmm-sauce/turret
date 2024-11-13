extends Button


func _process(delta: float) -> void:
	if get_parent().get_node("cannon").health < 0:
		$cannon/CanonExplode.play()
		$Death.visible = true
		$Death.play("Death")
		get_node("../GameOver").game_over()
		get_tree().paused = true
		get_parent().get_node("GameOver").visible = true
		get_parent().get_node("UI").visible = false

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_parent().get_node("Spawner").reset_game()
	get_parent().get_node("$GameOver").visible = false
	get_parent().get_node("UI").visible = true
	get_parent().coins = 0
	get_parent().get_node("UI").reset()
	get_parent().get_node("cannon").health = 500
	await get_tree().create_timer(1).timeout
	get_parent().get_node("cannon").health = 500
