extends Node2D

var trueParent
var speed = 1500  # Speed of the bullet in pixels per second

func _physics_process(delta):
	if $BulletSprite.visible:
		position += Vector2.RIGHT.rotated(rotation) * speed * delta
	if position.x > 3000 or position.x < -3000 or position.y > 3000 or position.y < -3000:
		queue_free()  # Remove the bullet when it goes off screen


func _on_bullet_area_entered(area: Area2D) -> void:
	if trueParent == "cannon" and not area.name == "Bullet":
		$BulletSprite.visible = false
		$Shrapnel.visible = true
		await get_tree().create_timer(0.05).timeout
		queue_free()


func _on_bullet_body_entered(body: Node2D) -> void:
	if trueParent == "enemy":
		body.health -= 15
		$BulletSprite.visible = false
		$Shrapnel.visible = true
		await get_tree().create_timer(0.05).timeout
		queue_free()
