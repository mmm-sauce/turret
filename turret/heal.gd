extends Area2D

var healAmount = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(1,10):
		scale = Vector2(float(i)/10, float(i)/10)
		await get_tree().create_timer(0.05).timeout
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func heal_collect():
	$AudioStreamPlayer2D.play()
	$Sprite2D.visible = false
	$Sprite2D2.visible = false
	get_parent().get_node("cannon").health += 20
	$Explosion.visible = true
	$Explosion.play("default")
	get_parent().get_node("Spawner").heals -= 1
	await get_tree().create_timer(.33).timeout
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Bullet" && area.get_parent().trueParent == "cannon":
		heal_collect()