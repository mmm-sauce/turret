extends Node2D

# Exported Variables
@export var enemyScene: PackedScene  # Reference to the enemy PackedScene (e.g., Enemy.tscn)
@export var spawnTimer: float = 5.0  # Initial time between spawns in seconds
@export var levelTime: float = 20.0  # Time after which spawn rate increases
@export var timeDecrease: float = 0.5  # Amount to decrease spawn interval
@export var minimumTime: float = 1.0  # Minimum allowed spawn interval

# Internal Variables
var elapsedTime: float = 0.0
var spawning = false

# Rectangle Dimensions (Portrait Orientation)
const RECT_WIDTH: float = 1080	# Width of the spawn area
const RECT_HEIGHT: float = 1920	# Height of the spawn area

func _ready() -> void:
	_spawn_enemy()
	
func _process(delta: float) -> void:
	elapsedTime += delta
	
	if not spawning:
		spawning = true
		await get_tree().create_timer(spawnTimer).timeout
		_spawn_enemy()
		spawning = false
		
	
	# Check if it's time to increase spawn speed
	if elapsedTime >= levelTime:
		_increase_spawn_speed()
		# Reset elapsed_time to prevent multiple increases
		elapsedTime = 0.0

func _spawn_enemy() -> void:
	
	# Instance the enemy scene
	var enemy = enemyScene.instantiate()
	
	# Determine a random spawn position on the border
	var spawn_position = get_random_border_position()
	
	# Set the enemy's global position
	enemy.global_position = spawn_position
	
	# Optional: Set the enemy's rotation to face the center (based on game design)
	enemy.rotation = (Vector2.ZERO - spawn_position).angle()
	
	# Add the enemy to the scene
	get_parent().add_child(enemy)



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

func _increase_spawn_speed() -> void:
	# Decrease the spawn interval to increase spawn rate
	spawnTimer = max(spawnTimer - timeDecrease, minimumTime)
	