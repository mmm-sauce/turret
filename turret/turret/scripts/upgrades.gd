extends Node2D

@export var cannon = CharacterBody2D
@export var spawner = Node2D

var tsCost = 5
var cdCost = 5
var bsCost = 5
var hpCost = 5

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
	
	$Upgrades/TurnSpeed/tsCost.text = "turn speed (" + str(cannon.turnSpeed) + ") - " + str(tsCost)+" coins"
	$Upgrades/Damage/dmgCost.text = "Damage (" + str(cannon.damage) + ") - " + str(cdCost)+" coins"
	$Upgrades/BurstShots/bsCost.text = "more shots (" + str(cannon.shots) + ") - " + str(bsCost)+" coins"
	$Upgrades/Health/hpCost.text = "Max health (" + str(cannon.maxHealth) + ") - " + str(hpCost)+" coins"
	
	$Level.text = "Level - "+str(spawner.level)
	
	$Coins.text = str(get_parent().coins)
	

func reset():
	cannon.turnSpeed = 4
	cannon.damage = 25
	cannon.shots = 1
	cannon.health = 25
	
	tsCost = 10
	cdCost = 10
	bsCost = 10
	hpCost = 10

func _on_turn_speed_pressed() -> void:
	if get_parent().coins >= tsCost:
		cannon.turnSpeed += .5
		get_parent().coins -= tsCost
		tsCost += 5
		$popupselect.play()
		

func _on_shot_cd_pressed() -> void:
	if get_parent().coins >= cdCost:
		cannon.damage = round(cannon.damage*1.2+25)
		get_parent().coins -= cdCost
		cdCost += 5
		$popupselect.play()


func _on_burst_shots_pressed() -> void:
	if get_parent().coins >= bsCost:
		cannon.shots += 1
		get_parent().coins -= bsCost
		bsCost += 5
		$popupselect.play()


func _on_health_pressed() -> void:
	if get_parent().coins >= hpCost:
		cannon.maxHealth += 100
		cannon.health += 100
		get_parent().coins -= hpCost
		hpCost += 5
		$popupselect.play()


func _on_popup_pressed() -> void:
	if not popping:
		popping = true
		
		# Changes step and max based on whether the menu is already out or not
		if popup == true: # seperation = 0
			$popupopen.play()
			for i in range(0, 51, 1):
				await get_tree().create_timer(.005).timeout
				
				Vseperation = EasingFunctions.ease_in_out_cubic(0, -100, float(i)/50)
			popup = false
		else:
			popup = true
			for i in range(0, 51, 1):
				await get_tree().create_timer(.005).timeout
				Vseperation = EasingFunctions.ease_out_bounce(-100, 0, float(i)/50)
		popping = false
		$popupclose.play()
