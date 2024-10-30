extends Node2D

@export var cannon = CharacterBody2D

var tsCost = 10
var cdCost = 10
var bsCost = 10

var popdown = false
var speed = .2


func _process(delta: float) -> void:
	$Upgrades/tsCost.text = str(tsCost)
	$Upgrades/cdCost.text = str(cdCost)
	$Upgrades/bsCost.text = str(bsCost)
	$Coins.text = str(get_parent().coins)
	
	if popdown:
		ease(speed, -3)
		print(speed)

func _on_turn_speed_pressed() -> void:
	if get_parent().coins >= tsCost:
		cannon.turnSpeed += 1
		get_parent().coins -= tsCost
		tsCost += 5
		

func _on_shot_cd_pressed() -> void:
	if get_parent().coins >= cdCost:
		cannon.shotCD = cannon.shotCD*.8
		get_parent().coins -= cdCost
		cdCost += 5


func _on_burst_shots_pressed() -> void:
	if get_parent().coins >= bsCost:
		cannon.shots += 1
		get_parent().coins -= bsCost
		bsCost += 5

func _on_popup_pressed() -> void:
	popdown = true
