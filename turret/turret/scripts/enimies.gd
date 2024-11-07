extends Node2D

var toSpawn = 0 # 1 for plane, 2 for strong plane 3 for tank, 4 for strong tank

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	$Plane.visible = false
	$"Strong Plane".visible = false
	$Tank.visible = false
	$"Strong Tank".visible = false
	
	if toSpawn == 0:
		$Plane.visible = true
		$Plane.reparent(get_parent())
	elif toSpawn == 1:
		$"Strong Plane".visible = true
		$"Strong Plane".reparent(get_parent())
	elif toSpawn == 2:
		$Tank.visible = true
		$Tank.reparent(get_parent())
	elif toSpawn == 3:
		$"Strong Tank".visible = true
		$"Strong Tank".reparent(get_parent())
