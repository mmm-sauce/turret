extends VBoxContainer

@export var cannon = CharacterBody2D

@onready var ts_cost: Label = $tsCost
@onready var cd_cost: Label = $cdCost
@onready var bs_cost: Label = $bsCost

var tsCost = 10
var cdCost = 10
var bsCost = 10

var speed = .2
var Vseperation = -100

var popup = false
var popping = false
var popArray = []


func _process(delta: float) -> void:
	if popup == true:
		get_parent().get_tree().paused = true
	elif popup == false:
		get_parent().get_tree().paused = false
	
	$Popup.rotation = Vseperation/-100 * 3.15
	
	$Sprite2D2.set_modulate(Color(1,1,1,(Vseperation+100)/100))
	$Upgrades.add_theme_constant_override("v_separation", Vseperation)
	
	$Upgrades/tsCost.text = "turn speed - "+str(tsCost)+" coins"
	$Upgrades/cdCost.text = "burst cooldown - "+str(cdCost)+" coins"
	$Upgrades/bsCost.text = "more shots - "+str(bsCost)+" coins"
	$Coins.text = str(get_parent().coins)
	
	

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
	if not popping:
		popping = true
		# Changes step and max based on whether the menu is already out or not
		if popup == true: # seperation = 0
			for i in range(0, 101, 1):
				await get_tree().create_timer(.005).timeout
				Vseperation = EasingFunctions.ease_in_out_cubic(0, -100, float(i)/100)
			popup = false
		else:
			popup = true
			for i in range(0, 101, 1):
				await get_tree().create_timer(.005).timeout
				Vseperation = EasingFunctions.ease_out_bounce(-100, 0, float(i)/100)
		popping = false
