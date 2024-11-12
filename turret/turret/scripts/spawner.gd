extends Node2D

# Exported Variables
@export var enemy_scene: PackedScene    # Reference to the enemy scene (enemies.tscn)
@export var heal_scene: PackedScene     # Reference to the heal scene
@export var spawn_interval: float = 5.0 # Time between enemy spawns
@export var level_duration: float = 30.0 # Time before level increases

# Constants
const SPAWN_AREA_WIDTH: float = 1080.0
const SPAWN_AREA_HEIGHT: float = 1920.0

# Internal Variables
var elapsed_time: float = 0.0
var level: int = 0
var max_difficulty: int = 10

var enemy_spawn_timer: float = 0.0
var heal_spawn_timer: float = 0.0

var current_enemies: Array = [0, 0, 0, 0] # Plane, Strong Plane, Tank, Strong Tank
var enemy_difficulties: Array = [1, 3, 5, 12]
var spawn_chances: Array = [1.0, 0.333, 0.2, 0.0833]
var true_spawn_chances: Array = [1.0, 0.333, 0.2, 0.0833]
var enemy_names: Array = ["Plane", "Strong Plane", "Tank", "Strong Tank"]

var current_heals: int = 0
var baseHealAmount = 50

var spawned = [] # Holds all spawned items

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	enemy_spawn_timer = spawn_interval
	heal_spawn_timer = rng.randf_range(5.0, 15.0)

func _process(delta: float) -> void:
	for i in spawn_chances.size():
		if i == 1:
			if level < 1:
				true_spawn_chances[i] = 0
			else:
				true_spawn_chances[i] = spawn_chances[i] / (level / 1.5)
		elif i == 2:
			if level < 3:
				true_spawn_chances[i] = 0
			else:
				true_spawn_chances[i] = spawn_chances[i] / (level / 2)
		elif i == 3:
			if level < 7:
				true_spawn_chances[i] = 0
			else:
				true_spawn_chances[i] = spawn_chances[i] / level
				
	print(spawn_chances)
	print(true_spawn_chances)
	
	if get_tree().paused:
		return

	elapsed_time += delta
	enemy_spawn_timer -= delta
	heal_spawn_timer -= delta

	# Level up after level_duration seconds
	if elapsed_time >= level_duration:
		level += 1
		elapsed_time = 0.0
		max_difficulty = level * 2 + 10

		# Scale spawn_interval with level (minimum 1.0 seconds)
		spawn_interval = clamp( 0.5 + 4.5 * exp(-0.3 * level), .5, 5.0)
		print("Level up to:", level, "New spawn interval:", spawn_interval)

	# Attempt to spawn an enemy
	if enemy_spawn_timer <= 0.0:
		enemy_spawn_timer = spawn_interval
		_attempt_spawn_enemy()

	# Attempt to spawn a heal
	if heal_spawn_timer <= 0.0:
		current_heals += 1
		heal_spawn_timer = randf_range(5.0, 10.0) * (current_heals^2 + 1)
		_spawn_heal()


func _attempt_spawn_enemy():
	# Calculate total difficulty of current enemies
	var total_difficulty = 0
	for i in range(current_enemies.size()):
		total_difficulty += enemy_difficulties[i] * current_enemies[i]

	var available_difficulty = max_difficulty - total_difficulty
	if available_difficulty <= 0:
		return

	# Choose an enemy type to spawn based on spawn chances
	var enemy_type = rng.rand_weighted(true_spawn_chances)
	if enemy_difficulties[enemy_type] <= available_difficulty:
		print("Attempting to spawn enemy type:", enemy_type)
		_spawn_enemy(enemy_type)
	else:
		print("Enemy type", enemy_type, "exceeds available difficulty.")

func on_enemy_destroyed(enemy_type: int) -> void:
	get_parent().coins += enemy_difficulties[enemy_type]
	if enemy_type >= 0 and enemy_type < current_enemies.size():
		current_enemies[enemy_type] -= 1
		print("Enemy destroyed. Type:", enemy_type, "Remaining:", current_enemies[enemy_type])
	else:
		print("Invalid enemy_type in on_enemy_destroyed:", enemy_type)

func _spawn_enemy(enemy_type: int):
	print("Spawning enemy type:", enemy_type)
	var enemy_container = enemy_scene.instantiate()
	if enemy_container == null:
		print("Failed to instantiate enemy_scene.")
		return

	# Access the correct child node within the instantiated enemy_container
	var enemy_node = null
	match enemy_type:
		0:
			enemy_node = enemy_container.get_node("Plane")
		1:
			enemy_node = enemy_container.get_node("Strong Plane")
		2:
			enemy_node = enemy_container.get_node("Tank")
		3:
			enemy_node = enemy_container.get_node("Strong Tank")
		_:
			print("Invalid enemy type:", enemy_type)
			return

	if enemy_node == null:
		print("Failed to find enemy node for type:", enemy_type)
		return

	# Assign the enemy_type
	enemy_node.enemy_type = enemy_type
	current_enemies[enemy_type] += 1

	# Reparent the enemy node to the main scene
	enemy_container.toSpawn = enemy_type
	enemy_container.remove_child(enemy_node)
	get_parent().add_child(enemy_node)
	enemy_node.global_position = get_random_border_position()
	enemy_container.queue_free()
	
	spawned.append(enemy_node)
	
	print("Enemy spawned and added to scene.")

func get_random_border_position() -> Vector2:
		# Randomly select one of the four sides: 0=Top, 1=Right, 2=Bottom, 3=Left
	var side = randi() % 4
	var pos = Vector2.ZERO
	
	match side:
		0:	# Top Side
			pos.x = randf_range(0, SPAWN_AREA_WIDTH)
			pos.y = 0
		1:	# Right Side
			pos.x = SPAWN_AREA_WIDTH
			pos.y = randf_range(0, SPAWN_AREA_HEIGHT)
		2:	# Bottom Side
			pos.x = randf_range(0, SPAWN_AREA_WIDTH)
			pos.y = SPAWN_AREA_HEIGHT
		3:	# Left Side
			pos.x = 0
			pos.y = randf_range(0, SPAWN_AREA_HEIGHT)
	
	return pos

func reset_game() -> void:
	level = 0
	elapsed_time = 0.0
	max_difficulty = 10
	
	enemy_spawn_timer = spawn_interval
	heal_spawn_timer = rng.randf_range(5.0, 15.0)
	
	current_enemies = [0, 0, 0, 0]
	current_heals = 0
	
	# Remove existing entities
	for node in spawned:
		if is_instance_valid(node):
			node.queue_free()
	
	
	print("Game has been reset to level 0.")

func _spawn_heal():
	var heal = heal_scene.instantiate()
	heal.healAmount = baseHealAmount * (level*.5+1)
	heal.position = Vector2(
		rng.randf_range(50.0, SPAWN_AREA_WIDTH - 50.0),
		rng.randf_range(50.0, SPAWN_AREA_HEIGHT - 50.0)
	)
	get_parent().add_child(heal)
	spawned.append(heal)
