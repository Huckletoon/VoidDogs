extends Control

var alph = 0
var fadeSpeed = 0.8

func _ready():
	get_node("CenterContainer/VBoxContainer/Retry").grab_focus()
	
func _physics_process(delta):
	if alph < 1:
		alph += fadeSpeed * delta
		get_node("CenterContainer").self_modulate = Color(1,1,1,alph)

func _on_Quit_pressed():
	get_tree().quit()


func _on_Title_pressed():
	get_parent().returnToTitle()


func _on_Retry_pressed():
	get_parent().retry()
