extends Node2D

var coins = 0

func _process(delta: float) -> void:
	if $cannon.health < 0:
		get_tree().paused = true
		$Button.visible = true
		$UI.visible = false

func _on_button_pressed() -> void:
	get_tree().paused = false
	$Spawner.reset_game()
	$Button.visible = false
	$UI.visible = true
	coins = 0
