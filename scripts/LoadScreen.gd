extends Node2D

var font = preload("res://fonts/xolonium/xolonium.tres")

onready var sprite = get_node("Sprite")

func _physics_process(delta):
	var centerX = get_viewport().size.x / 2
	var centerY = get_viewport().size.y / 2
	sprite.rotate(delta*5)
	sprite.position = Vector2(centerX, centerY)
	update()
	
func _draw():
	draw_string(font, sprite.position + Vector2(-34, 64), "Loading...")