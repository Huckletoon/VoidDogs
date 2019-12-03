extends Control

onready var game = get_tree().current_scene
onready var upgrade0 = get_node("Upgrades/Container/Upgrade0")
onready var upgrade1 = get_node("Upgrades/Container/Upgrade1")
onready var button = get_node("ButtonContainer/HBoxContainer/Button")
var upgrade0Text = ""
var upgrade1Text = ""
var nextLevel

func _on_Button_pressed():
	game.nextLevel()
	
func _ready():
	upgrade0.get_node("Label").text = upgrade0Text
	upgrade1.get_node("Label").text = upgrade1Text
	button.visible = false

# Used to set up dialogue and different upgrades
#TODO: Dialogue
func setLevel(level):
	nextLevel = level
	match level:
		1.5: #FireRate or Evade
			upgrade0Text = "Offense\nFire Rate Up"
			upgrade1Text = "Defense\nEvasion Up"
		2: #Damage or Health
			upgrade0Text = "Offense\nDamage Up"
			upgrade1Text = "Defense\nHealth Up"
		2.5: #LaserSize or Movement
			upgrade0Text = "Offense\nLaser Size Up"
			upgrade1Text = "Defense\nMovement Up"
		3: #FireRate or Health
			upgrade0Text = "Offense\nFire Rate Up"
			upgrade1Text = "Defense\nHealth Up"
		3.5: #Cooling or Evade
			upgrade0Text = "Offense\nCooling Up"
			upgrade1Text = "Defense\nEvasion Up"
		4: #Evade and Cooling
			pass


func _on_Upgrade0_gui_input(event):
	if event.is_class("InputEventMouseButton") and !event.pressed:
		match nextLevel:
			1.5:
				game.stage1Upgrade = 1
			2:
				game.stage2Upgrade = 1
			2.5: 
				game.stage3Upgrade = 1
			3: 
				game.stage4Upgrade = 1
			3.5:
				game.stage5Upgrade = 1
		button.visible = true


func _on_Upgrade1_gui_input(event):
	if event.is_class("InputEventMouseButton") and !event.pressed:
		match nextLevel:
			1.5:
				game.stage1Upgrade = 2
			2: 
				game.stage2Upgrade = 2
			2.5: 
				game.stage3Upgrade = 2
			3: 
				game.stage4Upgrade = 2
			3.5: 
				game.stage5Upgrade = 2
		button.visible = true
