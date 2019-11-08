extends Area2D

class_name Enemy

var rng = RandomNumberGenerator.new()
var vel = Vector2()
var lookDir = Vector2()
var rotTracker = 0
var player

const MAX_SPEED = 300
const ACCEL = 20
const DRAG = 10
const CLASS = "Enemy"

onready var sprite = get_node("Sprite")

func is_type(type):
	return type == CLASS
	
func get_type():
	return CLASS

func destroy():
	get_parent().ships.erase(self)
	self.queue_free()

func _ready():
	rng.randomize()
	rotTracker = rng.randf_range(0, 2*PI)

func _physics_process(delta):
	
	#DEBUG
	#Fly in a circle
	rotTracker += delta
	if rotTracker >= 2*PI: rotTracker = 0
	lookDir = Vector2(sin(rotTracker), -cos(rotTracker))
	sprite.rotation = rotTracker
	vel.x += ACCEL * lookDir.x
	vel.y += ACCEL * lookDir.y
	if vel.y > 0: vel.y -= DRAG
	elif vel.y < 0: vel.y += DRAG
	if vel.x > 0: vel.x -= DRAG
	elif vel.x < 0: vel.x += DRAG
	
	vel = vel.clamped(MAX_SPEED)
	position += vel*delta
	
	pass
	
#DEBUG
#func _draw():
#	draw_line(Vector2(0,0),100*lookDir, Color.aqua, 3.0, true)
#	draw_line(Vector2.ZERO, 100 * vel.normalized(), Color.coral, 3.0, true)