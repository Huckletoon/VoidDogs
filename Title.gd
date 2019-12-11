extends Node

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_node("CenterContainer/VSplitContainer/VBoxContainer/Start").grab_focus()

func _process(delta):
	if get_tree().paused: get_tree().paused = false

func _on_Start_pressed():
	get_parent().startGame(0)


func _on_Exit_pressed():
	get_tree().quit()
