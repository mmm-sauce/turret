extends VBoxContainer

@export var cannon = CharacterBody2D

var tsCost = 10
var cdCost = 10
var bsCost = 10

func _process(delta: float) -> void:
	get_node("tsCost").text = str(tsCost)
	get_node("cdCost").text = str(cdCost)
	get_node("bsCost").text = str(bsCost)

func _on_turn_speed_pressed() -> void:
	cannon.turnSpeed += 1
	tsCost += 5


func _on_shot_cd_pressed() -> void:
	cannon.shotCD = cannon.shotCD*.5
	cdCost += 5


func _on_burst_shots_pressed() -> void:
	cannon.shots += 1
	bsCost += 5
