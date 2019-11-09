extends Node

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if get_tree().paused: get_tree().paused = false
	if Input.is_action_just_pressed("pl_start"):
		get_tree().change_scene("res://World.tscn")

func _on_Start_pressed():
	get_tree().change_scene("res://World.tscn")


func _on_Exit_pressed():
	get_tree().quit()
