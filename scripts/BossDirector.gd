extends Node

var VoidDog = preload("res://objects/VoidDog.tscn")

var rng = RandomNumberGenerator.new()
var objective = false

var voidDog
var player

const RADIUS = 2000

func _ready():
	rng.randomize()
	voidDog = VoidDog.instance()
	player = get_node("../Player")
	voidDog.player = player
	
	var angle = rng.randf_range(0, 2*PI)
	voidDog.position = Vector2(sin(angle), cos(angle)) * RADIUS
	player.position = Vector2(sin(angle+PI), cos(angle+PI)) * RADIUS
	add_child(voidDog)