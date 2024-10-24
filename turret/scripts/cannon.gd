extends CharacterBody2D

@export var bullet_scene: PackedScene
const turnSpeed = 5
var barrel = 1

var shots = 2 # Number of shots per burst (can be upgraded)
var shoot = false
var clickPos = Vector2.ZERO 
var clickAngle = 0

var shotCD = .5  # Shot Cooldown time (can be upgraded)
var shotTimer = 0.0  # Timer to track the cooldown


# Set the click angle to the angle of the most recent click
func _input(event):
	if event is InputEventMouseButton && shoot == false:
		clickPos = event.position  
		var direction = (clickPos - position).normalized()
		clickAngle = direction.angle()
		await get_tree().create_timer(shotTimer).timeout
		shoot = true

func _physics_process(delta: float) -> void:
	
	
	# Picks between turning CW and CCW depending on shortest distance
	var angleDiff = clickAngle - rotation
	angleDiff = wrapf(angleDiff, -PI, PI)
	
	# Rotate towards the click
	rotation += sign(angleDiff) * min(abs(angleDiff), turnSpeed * delta)
	
	# Handles the shooting logic
	if shoot == true and abs(angleDiff) < 0.01:
		shoot = false
		shotTimer = shotCD
		for i in shots:
			await get_tree().create_timer(.1).timeout
			fire_bullet()
	
	# Logic for timer between shots
	if shotTimer > 0:
		shotTimer -= delta
		print(shotCD)
	
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
	
