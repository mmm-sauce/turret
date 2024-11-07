extends Node2D

# Exported Variables
@export var enemyScene: PackedScene  # Reference to the enemy PackedScene (e.g., enemies.tscn)
@export var healScene: PackedScene  # Reference to the heal PackedScene (e.g., heal.tscn)
@export var spawnTimer: float = 5.0  # Initial time between spawns in seconds
@export var levelTime: float = 20.0  # Time after which spawn rate increases
@export var timeDecrease: float = 0.5  # Amount to decrease spawn interval
@export var minimumTime: float = 1.0  # Minimum allowed spawn interval

# Internal Variables
var elapsedTime: float = 0.0
var enemySpawning = false
var healSpawning = false
var heals = 0
var maxHeals = 3
var level = 0



# Rectangle Dimensions (Portrait Orientation)
const RECT_WIDTH: float = 1080	# Width of the spawn area
const RECT_HEIGHT: float = 1920	# Height of the spawn area

# Hanldes enemy spawning logic: 0 for plane, 1 for strong plane 2 for tank, 3 for strong tank
var rng = RandomNumberGenerator.new()
var currentEnimies = [0,0,0,0]
var enemyDifficulty = [1,4,3,12]
var difficultyScaling = 3
var difficultyDelta = 3
var spawningChance = [1,.25,.333,.0833]
var maxDifficulty = 10
var currentDifficulty = 0
var enemyNames = ["Plane","Strong Plane","Tank","Strong Tank"]

func _process(delta: float) -> void:
	
	determine_spawn()
	spawn_heal()
	
	
	# Check if it's time to increase spawn speed
	if not get_tree().paused == true:
		elapsedTime += delta
	
	if elapsedTime >= levelTime:
		level += 1
		# Reset elapsed_time to prevent multiple increases
		spawnTimer = max(spawnTimer - timeDecrease, minimumTime)
		elapsedTime = 0.0

func determine_spawn():
	
	maxDifficulty = level * difficultyScaling + 10
	
	difficultyDelta = maxDifficulty
	
	for i in currentEnimies:
		difficultyDelta -= enemyDifficulty[i] * currentEnimies[i]
	
	if difficultyDelta > 0:
		var toSpawn = [0,1,2,3][rng.rand_weighted(spawningChance)]
		if enemyDifficulty[toSpawn] > difficultyDelta:
			_spawn_enemy(toSpawn)

func _spawn_enemy(toSpawn) -> void:
	if not enemySpawning:
		enemySpawning = true
		await get_tree().create_timer(spawnTimer).timeout
		if not get_tree().paused == true:
				# Instance the enemy scene
				var enemy = enemyScene.instantiate()
				
				# Determine a random spawn position on the border
				var spawn_position = get_random_border_position()
				
				print(enemy.name)
				
				enemy.toSpawn = toSpawn
				
				# Set the enemy's global position
				enemy.global_position = spawn_position
				
				# Optional: Set the enemy's rotation to face the center (based on game design)
				enemy.rotation = (Vector2.ZERO - spawn_position).angle()
				
				# Add the enemy to the scene
				get_parent().add_child(enemy)
		enemySpawning = false



func get_random_border_position() -> Vector2:
	# Randomly select one of the four sides: 0=Top, 1=Right, 2=Bottom, 3=Left
	var side = randi() % 4
	var pos = Vector2.ZERO
	
	match side:
		0:	# Top Side
			pos.x = randf_range(0, RECT_WIDTH)
			pos.y = 0
		1:	# Right Side
			pos.x = RECT_WIDTH
			pos.y = randf_range(0, RECT_HEIGHT)
		2:	# Bottom Side
			pos.x = randf_range(0, RECT_WIDTH)
			pos.y = RECT_HEIGHT
		3:	# Left Side
			pos.x = 0
			pos.y = randf_range(0, RECT_HEIGHT)
	
	return pos

func spawn_heal():
	if not healSpawning && heals < maxHeals:
		heals += 1
		healSpawning = true
		await get_tree().create_timer(randi_range(5,15)).timeout
		if not get_tree().paused == true:
			var heal = healScene.instantiate()
			get_parent().add_child(heal)
			heal.position = Vector2(randf_range(20, RECT_WIDTH-20), randf_range(20, RECT_HEIGHT-20))
		healSpawning = false


func _increase_spawn_speed() -> void:
	# Decrease the spawn interval to increase spawn rate
	spawnTimer = max(spawnTimer - timeDecrease, minimumTime)
	
