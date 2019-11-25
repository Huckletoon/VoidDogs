extends Node2D

var vel = Vector2.ZERO
var spin = 0
var decay = 0

onready var sprite = get_node("Sprite")

func _physics_process(delta):
	
	#position += vel * delta
	sprite.rotate(spin * delta)
	sprite.scale -= Vector2(decay, decay) * delta
	if sprite.scale.x < 0:
		sprite.scale = Vector2.ZERO
		queue_free()

