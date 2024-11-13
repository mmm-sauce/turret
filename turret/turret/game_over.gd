extends CanvasLayer



func _ready():
	self.hide()
	

func game_over():
	get_tree().paused = true
	self.show()
	
