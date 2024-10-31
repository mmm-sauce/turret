extends CharacterBody2D

# Cannon Properties
@export var bullet_scene: PackedScene  # Reference to the bullet scene
var turnSpeed = 5  # Cannon rotation speed (*UPGRADEABLE!!!!)
var barrel = 1  # Alternates between barrels for firing
var health = 100 # Health
var isHeal = false # Is currently healing?



# Shooting Mechanics
var shots = 1  # Number of shots per burst (*UPGRADEABLE!!!!)
var shoot = false  # Indicates if the cannon should shoot
var clickPos = Vector2.ZERO  # Position of the last click
var clickAngle = 0  # Angle to rotate towards
var angleDiff = 0 # Difference between angles

# Timing
var shotTimer = 0.0  # Tracks cooldown between bursts
var shotCD = 0.5  # Cooldown time between bursts in seconds (*UPGRADEABLE!!!!)


# Set the click angle to the angle of the most recent click
func _input(event):
	if event is InputEventMouseButton and shoot == false:
		clickPos = event.position
		var direction = (clickPos - position).normalized()
		clickAngle = direction.angle()
		await get_tree().create_timer(shotTimer).timeout
		shoot = true

func _ready() -> void:
	$HealthBar.value = 100

func _physics_process(delta: float) -> void:
	
	if not isHeal:
		isHeal = true
		health = min(health + 5, 100)
		await get_tree().create_timer(.5).timeout
		isHeal = false
	
	if $HealthBar.value == 100:
		$HealthBar.visible = false
	else:
		$HealthBar.visible = true
	
	# Death hanlding
	if $HealthBar.value < 0.001:
		game_over()
	
	$HealthBar.value = health
	
	update_shot_timer(delta)

	# Rotate towards the click
	angleDiff = rotate_towards_click(delta)

	# Handles the shooting logic
	if shoot == true and abs(angleDiff) < 0.01:
		shoot = false
		shotTimer = shotCD
		for i in range(shots):
			await get_tree().create_timer(0.1).timeout
			fire_bullet()
			# $AudioStreamPlayer2D.play()

	handle_animation()
	
	$HealthBar.global_position = global_position - Vector2(73, 125)
	$HealthBar.rotation = -rotation

func game_over():
	pass

func rotate_towards_click(delta):
	var angleDiff = clickAngle - rotation
	angleDiff = wrapf(angleDiff, -PI, PI)

	rotation += sign(angleDiff) * min(abs(angleDiff), turnSpeed * delta)

	return angleDiff

func update_shot_timer(delta):
	if shotTimer > 0:
		shotTimer -= delta

func handle_animation():
	if $AnimatedSprite2D.is_playing() == false:
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
		$AnimatedSprite2D.pause()

func fire_bullet():
	# Handling barrel animation
	$AnimatedSprite2D.play('default')
	await get_tree().create_timer(0.1).timeout

	# Instancing the bullet
	var bullet = bullet_scene.instantiate()
	
	bullet.trueParent = "cannon"
	
	# Shooting bullet out of alternating barrels
	if barrel == 1:
		bullet.position = get_node("Marker2D").global_position
	else:
		bullet.position = get_node("Marker2D2").global_position

	barrel = barrel * -1

	# Ensuring the bullet shoots out the front of the cannon
	bullet.rotation = rotation

	# Adding bullet as a child of main scene
	get_parent().add_child(bullet)
