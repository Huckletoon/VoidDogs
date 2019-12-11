extends Control

onready var game = get_tree().current_scene
onready var upgrade0 = get_node("Upgrades/Container/Upgrade0")
onready var upgrade1 = get_node("Upgrades/Container/Upgrade1")
onready var button = get_node("ButtonContainer/HBoxContainer/Button")
var upgrade0Text = ""
var upgrade1Text = ""
var nextLevel
var selected = -1

func _on_Button_pressed():
	game.nextLevel()
	
func _ready():
	upgrade0.get_node("Label").text = upgrade0Text
	upgrade1.get_node("Label").text = upgrade1Text
	upgrade0.grab_focus()
	_on_Upgrade1_focus_exited()
	button.visible = false
	if nextLevel == 4.0:
		upgrade0.visible = false
		upgrade1.visible = false
		button.visible = true
		button.grab_focus()

# Used to set up dialogue and different upgrades
#TODO: Dialogue
func setLevel(level):
	nextLevel = level
	match level:
		1.5: #FireRate or Evade
			upgrade0Text = "Offense\nFire Rate Up"
			upgrade1Text = "Defense\nEvasion Up"
		2.0: #Damage or Health
			upgrade0Text = "Offense\nDamage Up"
			upgrade1Text = "Defense\nHealth Up"
		2.5: #LaserSize or Movement
			upgrade0Text = "Offense\nLaser Size Up"
			upgrade1Text = "Defense\nMovement Up"
		3.0: #FireRate or Health
			upgrade0Text = "Offense\nFire Rate Up"
			upgrade1Text = "Defense\nHealth Up"
		3.5: #Cooling or Evade
			upgrade0Text = "Offense\nCooling Up"
			upgrade1Text = "Defense\nEvasion Up"
		4.0: #Evade and Cooling
			pass
		_: print(level)


func _on_Upgrade0_gui_input(event):
	if (event.is_class("InputEventMouseButton") and !event.pressed) or (event.is_class("InputEventJoypadButton") and event.button_index == JOY_XBOX_A and event.pressed):
		match nextLevel:
			1.5:
				game.stage1Upgrade = 1
			2.0:
				game.stage2Upgrade = 1
			2.5: 
				game.stage3Upgrade = 1
			3.0: 
				game.stage4Upgrade = 1
			3.5:
				game.stage5Upgrade = 1
		button.visible = true
		selected = 0
		upgrade0.focus_neighbour_top = button.get_path()
		upgrade1.focus_neighbour_bottom = button.get_path()
		button.focus_neighbour_top = upgrade1.get_path()
		button.focus_neighbour_bottom = upgrade0.get_path()
		upgrade0.get_node("Label").text = upgrade0Text + "\nSelected"
		upgrade1.get_node("Label").text = upgrade1Text


func _on_Upgrade1_gui_input(event):
	if (event.is_class("InputEventMouseButton") and !event.pressed) or (event.is_class("InputEventJoypadButton") and event.button_index == JOY_XBOX_A and event.pressed):
		match nextLevel:
			1.5:
				game.stage1Upgrade = 2
			2.0: 
				game.stage2Upgrade = 2
			2.5: 
				game.stage3Upgrade = 2
			3.0: 
				game.stage4Upgrade = 2
			3.5: 
				game.stage5Upgrade = 2
		button.visible = true
		selected = 1
		upgrade0.focus_neighbour_top = button.get_path()
		upgrade1.focus_neighbour_bottom = button.get_path()
		button.focus_neighbour_top = upgrade1.get_path()
		button.focus_neighbour_bottom = upgrade0.get_path()
		upgrade1.get_node("Label").text = upgrade1Text + "\nSelected"
		upgrade0.get_node("Label").text = upgrade0Text
	


func _on_Upgrade0_focus_entered():
	upgrade0.set_modulate(Color(1, 1, 1, 1))


func _on_Upgrade1_focus_entered():
	upgrade1.set_modulate(Color(1, 1, 1, 1))


func _on_Upgrade0_focus_exited():
	upgrade0.set_modulate(Color(0.8, 0.8, 0.8, 1))


func _on_Upgrade1_focus_exited():
	upgrade1.set_modulate(Color(0.8, 0.8, 0.8, 1))
