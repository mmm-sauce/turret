extends Node2D

var toSpawn = 0 # 1 for plane, 2 for strong plane 3 for tank, 4 for strong tank

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Plane.visible = false
	$"Strong Plane".visible = false
	$Tank.visible = false
	$"Strong Tank".visible = false
	
	if toSpawn == 1:
		$Plane.visible = true
	elif toSpawn == 2:
		$"Strong Plane".visible = true
	elif toSpawn == 3:
		$Tank.visible = true
	elif toSpawn == 4:
		$"Strong Tank".visible = true
