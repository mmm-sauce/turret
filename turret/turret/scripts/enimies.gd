extends Node2D

var toSpawn = 0 # 1 for plane, 2 for strong plane 3 for tank, 4 for strong tank
var spawned = 0
var enemyNames = ["Plane","Strong Plane","Tank","Strong Tank"]

const RECT_WIDTH: float = 1080	# Width of the spawn area
const RECT_HEIGHT: float = 1920	# Height of the spawn area


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#$Plane.visible = false
	#$"Strong Plane".visible = false
	#$Tank.visible = false
	#$"Strong Tank".visible = false
	#
	#if toSpawn == 0:
		#$Plane.visible = true
	#elif toSpawn == 1:
		#$"Strong Plane".visible = true
	#elif toSpawn == 2:
		#$Tank.visible = true
	#elif toSpawn == 3:
		#$"Strong Tank".visible = true
		#
		
	var spawn_position = get_random_border_position()
	
	# Set the enemy's global position
	get_node(enemyNames[toSpawn]).global_position = spawn_position
	
	# Optional: Set the enemy's rotation to face the center (based on game design)
	get_node(enemyNames[toSpawn]).rotation = (Vector2.ZERO - spawn_position).angle()




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
