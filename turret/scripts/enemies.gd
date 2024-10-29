extends Area2D

# Bullet properties
@export var bullet_scene: PackedScene  # Reference to the bullet scene

# Firing control variables
var is_firing = false
var shotTimer = 1  # Time between shots

# Cannon properties
var cannonPos = Vector2(540, 960)  # Position of the cannon
var cannonAngle = 0  # Angle to rotate towards

# Plane properties 
var angleDiff = 0  # Difference between angles
var turnSpeed = 0.9  # Speed of rotation
var speed = 200  # Speed of movement
var trueSpeed = 0 # Speed used for calculations


func _ready() -> void:
	$HealthBar.value = 100

func _physics_process(delta: float) -> void:
	$HealthBar.global_position = $Plane.global_position - Vector2(73, 75)
	$HealthBar.rotation = -rotation  # Counteract the plane's rotation
	
	# Calculate direction and angle to cannon
	var cannonDirection = (cannonPos - position).normalized()
	cannonAngle = cannonDirection.angle()
	angleDiff = rotate_towards_cannon(delta)
	
	# Move forward in the direction the node is facing
	var direction = Vector2.RIGHT.rotated(rotation)
	trueSpeed = remap(abs(angleDiff), 0, 3.6, 1, 1.1) * speed
	position += direction * trueSpeed * delta
	
	print(angleDiff)
	
	angleDiff = randf_range(.99, 1.01) * angleDiff
	
	print(angleDiff)
	
	# Fire bullet when aligned with cannon and not already firing
	if abs(angleDiff) < 0.001 and not is_firing:
		is_firing = true
		$HealthBar.value -= 5
		fire_bullet()
		await get_tree().create_timer(shotTimer).timeout
		is_firing = false
	
	if $HealthBar.value < 0:
		queue_free()

func rotate_towards_cannon(delta):
	# Calculate angle difference and normalize it
	var angleDiff = cannonAngle - rotation
	angleDiff = wrapf(angleDiff, -PI, PI)
	
	# Rotate towards the cannon
	rotation += sign(angleDiff) * min(abs(angleDiff), turnSpeed * delta)
	
	# Update shadow position to match plane's position
	$Shadow.global_position = $Plane.global_position + Vector2(0, 20)
	
	return angleDiff

func fire_bullet():
	# Instance the bullet
	var bullet = bullet_scene.instantiate()
	
	# Set bullet position to the marker's global position
	bullet.position = get_node("Marker2D").global_position
	
	# Set bullet rotation to match current rotation
	bullet.rotation = rotation
	
	# Add bullet to the scene
	get_parent().add_child(bullet)
