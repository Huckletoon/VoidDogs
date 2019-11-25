extends Node2D

var leftExtent = 0
var rightExtent = 0
var height = 100
var pad = 32

var rect = Rect2()
var font = preload("res://fonts/xolonium/xolonium.tres")
onready var radar = get_parent()

#TODO
func _physics_process(delta):
	var width = get_viewport_rect().size.x
	var sheight = get_viewport_rect().size.y
	leftExtent = width / 6 + pad * 2
	rightExtent = width / 7 + pad
	var X = width / -2 + leftExtent
	var Y = sheight / 2 - pad - height
	var pos = Vector2(X, Y)
	pos += radar.camOff
	rect = Rect2(pos, Vector2(get_viewport_rect().size.x - leftExtent - rightExtent, height))
	update()
	
func _draw():
	draw_rect(rect, Color(0.3, 0.3, 0.3, 0.4))
	draw_string(font, rect.position + Vector2(8, 32), "You're done there, get back to the Carrier!")