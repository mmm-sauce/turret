extends Area2D

# Exported Variables
@export var bullet_scene: PackedScene    # Reference to the bullet scene
@export var enemy_type: int = -1         # Enemy type index (set by spawner)

# Constants
const CANNON_POSITION = Vector2(540, 960)

# Enemy Properties
var health: int
var max_health: int
var damage: int
var speed: float
var shot_timer: float
var is_firing: bool = false
var has_reached_cannon: bool = false

# Internal Variables
var cannon_angle: float = 0.0
var angle_difference: float = 0.0
var turn_speed: float = 1.5

func _ready() -> void:
	# Initialize enemy properties based on enemy_type
	match enemy_type:
		2:  # Tank
			health = 200
			max_health = 200
			damage = 50
			speed = 75.0
			shot_timer = 3.0
		3:  # Strong Tank
			health = 500
			max_health = 500
			damage = 150
			speed = 50.0
			shot_timer = 7.0
		_:
			print("Invalid enemy_type for Tank:", enemy_type)
			queue_free()
			return

	# Initialize health bar
	$HealthBar.value = health
	$HealthBar.max_value = max_health
	print("Enemy initialized with type:", enemy_type)

func _physics_process(delta: float) -> void:
	if visible and $Body.visible:

		# Update health bar
		$HealthBar.global_position = $Body.global_position - Vector2(73, 75)
		$HealthBar.rotation = -rotation
		$HealthBar.value = health

		# Handle death
		if health <= 0:
			_explode()
			return

		# Adjust angle towards the cannon
		_adjust_angle(delta)

		# Move forward if not at the cannon
		if not has_reached_cannon:
			var direction = Vector2.RIGHT.rotated(rotation)
			global_position += direction * speed * delta

		# Fire bullet when aligned with cannon
		if abs(angle_difference) < 0.01 and not is_firing and global_position.distance_to(CANNON_POSITION) < 500.0:
			is_firing = true
			_fire_bullet()
			await get_tree().create_timer(shot_timer).timeout
			is_firing = false

func _adjust_angle(delta: float) -> void:
	var direction_to_cannon = (CANNON_POSITION - global_position).normalized()
	cannon_angle = direction_to_cannon.angle()

	if not has_reached_cannon and global_position.distance_to(CANNON_POSITION) < 350.0:
		has_reached_cannon = true
		await get_tree().create_timer(2.0).timeout
	elif not has_reached_cannon:
		_rotate_towards_cannon(delta)

func _rotate_towards_cannon(delta: float) -> void:
	angle_difference = cannon_angle - rotation
	angle_difference = wrapf(angle_difference, -PI, PI)
	rotation += sign(angle_difference) * min(abs(angle_difference), turn_speed * delta)
	$Turret.global_position = global_position

func _fire_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	$Body/planeshoot.play()
	bullet.global_position = $Marker2D.global_position
	bullet.rotation = rotation
	bullet.trueParent = "enemy"
	bullet.damage = damage
	get_parent().add_child(bullet)
	print("Bullet fired by enemy type:", enemy_type)

func _explode() -> void:
	$Body/planeexplode.play()
	$Turret.visible = false
	$Body.visible = false
	$Explosion.visible = true
	$Explosion.play("default")

	# Notify spawner about enemy destruction
	var spawner = get_parent().get_node("Spawner")
	spawner.on_enemy_destroyed(enemy_type)

	await get_tree().create_timer(0.33).timeout
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Bullet" and area.get_parent().trueParent == "cannon":
		health -= get_parent().get_node("cannon").damage
		$HealthBar.visible = true
		print("Enemy hit by cannon. New health:", health)
