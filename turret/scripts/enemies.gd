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
var team = "enemy"
var angleDiff = 0  # Difference between angles
var turnSpeed = 1.5  # Speed of rotation
var speed = 300  # Speed of movement
var has_reached_cannon = false  # Indicates if the plane has reached the cannon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
		
	# Stop when dead
	if $Plane.visible:
		
		# Death hanlding
		if $HealthBar.value < 0.001:
			plane_explode()
		
		$HealthBar.global_position = $Plane.global_position - Vector2(73, 75)
		$HealthBar.rotation = -rotation  # Keep the health bar upright
		
		# Determine the angle to rotate towards
		adjust_angle(delta)

		# Move forward in the direction the plane is facing
		var direction = Vector2.RIGHT.rotated(rotation)
		global_position += direction * speed * delta
		
		# Fire bullet when aligned with cannon and not already firing
		if abs(angleDiff) < 0.001 and not is_firing and not has_reached_cannon and global_position.distance_to(cannonPos) < 500:
			is_firing = true
			fire_bullet()
			await get_tree().create_timer(shotTimer).timeout
			is_firing = false

func plane_explode():
	$Shadow.visible = false
	$Plane.visible = false
	get_parent().coins += 2
	$Explosion.visible = true
	$Explosion.play("default")
	await get_tree().create_timer(.33).timeout
	queue_free()

func adjust_angle(delta):
	var cannonDirection = (cannonPos - global_position).normalized()
	cannonAngle = cannonDirection.angle()
	
	# Check if the plane has reached the cannon
	if not has_reached_cannon and global_position.distance_to(cannonPos) < 50:
		has_reached_cannon = true
		angleDiff = 0
		await get_tree().create_timer(2).timeout
		rotation += randf_range(.1,-.1)
		has_reached_cannon = false

	elif not has_reached_cannon:
		angleDiff = rotate_towards_cannon(delta)

func rotate_towards_cannon(delta):
	# Calculate angle difference and normalize it
	var angleDiff = cannonAngle - rotation
	angleDiff = wrapf(angleDiff, -PI, PI)
	
	# Rotate towards the target angle
	rotation += sign(angleDiff) * min(abs(angleDiff), turnSpeed * delta)
	
	# Update shadow position
	$Shadow.global_position = $Plane.global_position + Vector2(0, 20)
	
	return angleDiff

func fire_bullet():
	# Instance the bullet
	var bullet = bullet_scene.instantiate()
	
	# Set bullet position and rotation
	bullet.global_position = $Marker2D.global_position
	bullet.rotation = rotation
	
	bullet.trueParent = "enemy"
	
	# Add bullet to the scene
	get_parent().add_child(bullet)


func _on_area_entered(area: Area2D) -> void:
	if area.name == "Bullet" && area.get_parent().trueParent == "cannon":
		$HealthBar.value -= 25
		$HealthBar.visible = true
