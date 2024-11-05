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
var has_reached_cannon = false  # Indicates if the plane has reached the cannon

# Variables between strengths
var health = 500
var maxHealth = 500
var strongHealth = 1000
var maxStrongHealth = 1000

var speed = 100
var strongSpeed = 150

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if name == "Strong Tank":
		health = strongHealth
		maxHealth = maxStrongHealth
		
	$HealthBar.value = health
	$HealthBar.max_value = maxHealth

func _physics_process(delta: float) -> void:
		
	# Stop when dead
	if $Body.visible:
		
		# Death hanlding
		if $HealthBar.value < 0.001:
			plane_explode()
		
		$HealthBar.global_position = $Body.global_position - Vector2(73, 75)
		$HealthBar.rotation = -rotation  # Keep the health bar upright
		$HealthBar.value = health
		
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
	$Body/planeexplode.play()
	$Turret.visible = false
	$Body.visible = false
	get_parent().get_parent().coins += 2
	$Explosion.visible = true
	$Explosion.play("default")
	
	if name == "Strong Tank":
		get_parent().currentEnimies[4]-=1
	else:
		get_parent().currentEnimies[3]-=1
		
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
	$Turret.global_position = $Body.global_position + Vector2(0, 20)
	
	return angleDiff

func fire_bullet():
	# Instance the bullet
	var bullet = bullet_scene.instantiate()
	$Body/planeshoot.play()
	
	# Set bullet position and rotation
	bullet.global_position = $Marker2D.global_position
	bullet.rotation = rotation
	
	bullet.trueParent = "enemy"
	# Add bullet to the scene
	
	get_parent().add_child(bullet)


func _on_area_entered(area: Area2D) -> void:
	if area.name == "Bullet" && area.get_parent().trueParent == "cannon":
		health -= get_parent().get_parent().get_node("cannon").damage
		$HealthBar.visible = true
