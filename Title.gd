extends Node

func _process(delta):
	if Input.is_action_just_pressed("pl_start"):
		get_tree().change_scene("res://World.tscn")

func _on_Start_pressed():
	get_tree().change_scene("res://World.tscn")


func _on_Exit_pressed():
	get_tree().quit()
