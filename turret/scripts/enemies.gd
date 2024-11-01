extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func rotate_towards_cannon(delta):
	# Calculate angle difference and normalize it
	var angleDiff = cannonAngle - rotation
	angleDiff = wrapf(angleDiff, -PI, PI)
	


func _on_body_entered(body: Node2D) -> void:
	get_parent().get_parent().get_node("label")
	queue_free()
