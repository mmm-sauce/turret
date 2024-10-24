extends CharacterBody2D

@export var bullet_scene: PackedScene
const turnSpeed = 5
var barrel = 1

var clickPos = Vector2.ZERO 
var clickAngle = 0

# Set the click angle to the angle of the most recent click
#func _input(event):
	#if event is InputEventMouseButton:
		#clickPos = event.position  
		#var direction = (clickPos - position).normalized()
		#clickAngle = direction.angle()
		#shoot = true

func _physics_process(delta: float) -> void:
	
	clickPos = get_global_mouse_position()
	var direction = (clickPos - position).normalized()
	clickAngle = direction.angle()
	
	# Picks between turning CW and CCW depending on shortest distance
	var angleDiff = clickAngle - rotation
	angleDiff = wrapf(angleDiff, -PI, PI)
	
	# Rotate towards the click
	rotation += sign(angleDiff) * min(abs(angleDiff), turnSpeed * delta)
	
	if Input.is_mouse_button_pressed(1) and angleDiff == 0:
		await get_tree().create_timer(.1).timeout
		fire_bullet()
	
	#Input handling
	if Input.is_action_pressed("turn_left"):
		rotate(-turnSpeed)
	if Input.is_action_pressed("turn_right"):
		rotate(turnSpeed)
	
	#Shot animation handling
	if $AnimatedSprite2D.is_playing() == false:
		$AnimatedSprite2D.set_frame_and_progress(0,0)
		$AnimatedSprite2D.pause()

func fire_bullet():
	
	#Handling barrel animation
	$AnimatedSprite2D.play('default')
	
	await get_tree().create_timer(.1).timeout
	
	#Instancing the bullet
	var bullet = bullet_scene.instantiate()
	
	# Shooting bullet out of alternating barrels
	if barrel == 1:
		bullet.position = get_node("Marker2D").global_position
	else:
		bullet.position = get_node("Marker2D2").global_position
	
	barrel = barrel*-1
	
	#Ensuring the bullet shoots out the front of the cannon
	bullet.rotation = rotation
	
	#Adding bullet as a child of main scene
	get_parent().add_child(bullet)
	
