extends Control

var dialogueBase = preload("res://sprites/dialogue_base.png")
var font = preload("res://fonts/xolonium/xolonium.tres")
onready var game = get_tree().current_scene
onready var upgrade0 = get_node("Upgrades/Container/Upgrade0")
onready var upgrade1 = get_node("Upgrades/Container/Upgrade1")
onready var button = get_node("ButtonContainer/HBoxContainer/Button")
var upgrade0Text = ""
var upgrade1Text = ""
var nextLevel
var selected = -1
var dialogueBasePos = Vector2()
var dialogueLines = []
var dialogueIndex = 0
var linePercent = 0
var lineSubstr = 0
var showDialogue = true

func _on_Button_pressed():
	game.nextLevel()
	
func _ready():
	#DEBUG
	#setLevel(1.5)
	#DEBUG
	
	upgrade0.get_node("Label").text = upgrade0Text
	upgrade1.get_node("Label").text = upgrade1Text
	#upgrade0.grab_focus()
	upgrade0.visible = false
	upgrade1.visible = false
	_on_Upgrade1_focus_exited()
	button.visible = false
	dialogueBasePos.x = 250
	dialogueBasePos.y = get_viewport_rect().size.y - 125

func _physics_process(delta):
	
	if linePercent <= 1:
		linePercent += delta/1.1
	
	if Input.is_action_just_pressed("ui_accept"):
		if linePercent <= 1:
			linePercent = 1.01
		elif dialogueIndex < dialogueLines.size() - 1: 
			linePercent = 0
			dialogueIndex += 1
		elif dialogueIndex == dialogueLines.size() - 1 and showDialogue:
			showDialogue = false
			if nextLevel != 4.0:
				upgrade0.visible = true
				upgrade1.visible = true
				upgrade0.grab_focus()
			else:
				button.visible = true
				button.grab_focus()
	
	lineSubstr = min(dialogueLines[dialogueIndex].length(), floor(dialogueLines[dialogueIndex].length() * linePercent))
	
	update()

# Used to set up dialogue and different upgrades
#TODO: Dialogue
func setLevel(level):
	nextLevel = level
	match level:
		1.5: #FireRate or Evade
			upgrade0Text = "Offense\nFire Rate Up"
			upgrade1Text = "Defense\nEvasion Up"
			dialogueLines.append("Android: I am here for the Uniform Ordinance.")
			dialogueLines.append("Mechanic: Great. Here. I'll take your old scraps off your hands.")
			dialogueLines.append("Android: Is it within policy to keep the old hat?")
			dialogueLines.append("Mechanic: ...")
			dialogueLines.append("Mechanic: I don't care.")
			dialogueLines.append("Android: There was also an ordinance for ship improvements.")
			dialogueLines.append("Mechanic: Right. Personal ID, Ship ID, and your preferred modification.")
		2.0: #Damage or Health
			upgrade0Text = "Offense\nDamage Up"
			upgrade1Text = "Defense\nHealth Up"
			dialogueLines.append("Android: Another Improvement Ordinance was issued.")
			dialogueLines.append("Mechanic: (sighs) I know. Uniform Ordinance too, but not for the Rejects.")
			dialogueLines.append("Android: Do the uniforms upset you?")
			dialogueLines.append("Mechanic: I'm an engineer, not a tailor. Just like you're not a pilot.")
			dialogueLines.append("Android: But that is my current designation.")
			dialogueLines.append("Mechanic: ...")
			dialogueLines.append("Mechanic: PID, SID, and mod, kid.")
		2.5: #LaserSize or Movement
			upgrade0Text = "Offense\nLaser Size Up"
			upgrade1Text = "Defense\nMovement Up"
			dialogueLines.append("Android: Another Improvement Ordinance was issued.")
			dialogueLines.append("Mechanic: Hm. Do you recall your reactivation?")
			dialogueLines.append("Android: That is not relevant. However, yes, I do a little bit.")
			dialogueLines.append("Mechanic: You have a name?")
			dialogueLines.append("Baker: I was called Baker.")
			dialogueLines.append("Mechanic: Fair enough.")
			dialogueLines.append("Mechanic: IDs and mod.")
		3.0: #FireRate or Health
			upgrade0Text = "Offense\nFire Rate Up"
			upgrade1Text = "Defense\nHealth Up"
			dialogueLines.append("Mechanic: Still alive, huh?")
			dialogueLines.append("Baker: Yes. I have orders to receive routine maintenance.")
			dialogueLines.append("Mechanic: Good. I've had enough of sewing uniforms.")
			dialogueLines.append("Baker: ...Could you patch up my hat?")
			dialogueLines.append("Mechanic: ...")
			dialogueLines.append("Mechanic: Maybe next time.")
			dialogueLines.append("Mechanic: While you're here, let me know what you want for the next mod.")
		3.5: #Cooling or Evade
			upgrade0Text = "Offense\nCooling Up"
			upgrade1Text = "Defense\nEvasion Up"
			dialogueLines.append("Baker: I have been selected to pilot a new ship per the AWS Android Advancement Committee.")
			dialogueLines.append("Devonia: ...")
			dialogueLines.append("Devonia: Make sure you bring it back in one piece. They hounded me all week to finish it.")
			dialogueLines.append("Baker: Is it not an engineer's duty to do so?")
			dialogueLines.append("Devonia: Well yeah, but they could be nicer about it. I'm one of them, not an Android.")
			dialogueLines.append("Baker: ...Will I keep my previous modifications?")
			dialogueLines.append("Devonia: Yeah. Got another lined up, too.")
		4.0: #Evade and Cooling
			dialogueLines.append("Baker: I am here for the ship modifications as stated in the Planetary Acquisition Ordinance.")
			dialogueLines.append("Mechanic: Yeah, I heard. Makes sense they'd only send the last Reject.")
			dialogueLines.append("Baker: I was not told that I was going solo.")
			dialogueLines.append("Mechanic: You aren't told a lot.")
			dialogueLines.append("Baker: Are you?")
			dialogueLines.append("Mechanic: I'm an engineer, not an executive.")
			dialogueLines.append("Baker: I see. I will leave it to you, then. Goodbye, Devonia.")
			dialogueLines.append("Devonia: See you later, Baker.")
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
			4.0:
				game.finalUpgrade = true
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
	

func _draw():
	if showDialogue:
		draw_texture(dialogueBase, dialogueBasePos)
		draw_string(font, dialogueBasePos + Vector2(30, 40), dialogueLines[dialogueIndex].substr(0, lineSubstr))


func _on_Upgrade0_focus_entered():
	upgrade0.set_modulate(Color(1, 1, 1, 1))


func _on_Upgrade1_focus_entered():
	upgrade1.set_modulate(Color(1, 1, 1, 1))


func _on_Upgrade0_focus_exited():
	upgrade0.set_modulate(Color(0.8, 0.8, 0.8, 1))


func _on_Upgrade1_focus_exited():
	upgrade1.set_modulate(Color(0.8, 0.8, 0.8, 1))

