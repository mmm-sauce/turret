extends Node2D

var speed = 1500  # Speed of the bullet in pixels per second

func _physics_process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	if position.x > 3000 or position.x < -3000 or position.y > 3000 or position.y < -3000:
		queue_free()  # Remove the bullet when it goes off screen
