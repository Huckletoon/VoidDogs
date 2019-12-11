extends Control

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_node("CenterContainer/VBoxContainer/Resume").grab_focus()



func _on_Resume_pressed():
	get_parent().unpause()


func _on_Options_pressed():
	get_parent().options()


func _on_QuitMenu_pressed():
	get_parent().returnToTitle()


func _on_QuitDesktop_pressed():
	get_tree().quit()
