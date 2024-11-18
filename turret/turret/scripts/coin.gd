extends Area2D

var CoinAmount = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(1,10):
		scale = Vector2(EasingFunctions.ease_in_out_cubic(0, 1, float(i)/10), EasingFunctions.ease_in_out_cubic(0, 1, float(i)/10))
		await get_tree().create_timer(0.05).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.distance_to(Vector2(540, 960)) < 100.0:
		queue_free()
	

func coin_collect():
	$Sprite2D.visible = false
	#$coinsfx.play() #- add sfx later
	#get_parent().get_node("cannon").health += CoinAmount #legacy - gives some health as a bonus, for testing purposes
	get_parent().coins += CoinAmount
	$Explosion.visible = true
	$Explosion.play("default")
	get_parent().get_node("Spawner").current_coins -= 1
	await get_tree().create_timer(.33).timeout
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Bullet" && area.get_parent().trueParent == "cannon" && $Sprite2D.visible:
		coin_collect()
