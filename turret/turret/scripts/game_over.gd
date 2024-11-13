extends CanvasLayer


func _ready():
	self.hide

func game_over():
	get_tree().paused = true
	self.show()
	

func _on_restart_pressed() -> void:
	get_tree().change_scene("res://scenes/main.tscn")


func _on_quit_pressed() -> void:
	pass # Replace with function body.
