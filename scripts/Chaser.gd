extends Area2D

class_name Chaser

var Bullet = preload("res://objects/Bullet.tscn")

var rng = RandomNumberGenerator.new()
var vel = Vector2()
var lookDir = Vector2()
var player
var angle = 0
var fireRate = 10
var fireTrack = 0
var fireCool = 1000
var bulletSpeed = 1000

const MAX_SPEED = 500
const ACCEL = 23
const DRAG = 1
const CLASS = "Chaser"
const RANGE = 700
const ORBIT = 400

onready var sprite = get_node("Sprite")
onready var timer = get_node("Timer")

func is_type(type):
	return type == CLASS
	
func get_type():
	return CLASS

func destroy():
	get_parent().ships.erase(self)
	self.queue_free()

func _ready():
	rng.randomize()
	angle = rng.randf_range(0, 2*PI)
	timer.wait_time = 10
	timer.start()

func _physics_process(delta):
	
	var diff = player.position - self.position
	var dist = diff.length()
	if dist > RANGE:
		var orbit = Vector2(sin(angle), -cos(angle))
		diff += ORBIT*orbit
		diff = diff.normalized()
		vel += ACCEL * diff
		sprite.rotation = atan2(diff.y, diff.x) + PI/2
	else:
		diff = diff.normalized()
		sprite.rotation = atan2(diff.y, diff.x) + PI/2
		
		if fireTrack == 0:
			var bullet = Bullet.instance()
			bullet.team = 1
			bullet.position = position + diff*32
			bullet.velocity = diff * bulletSpeed
			bullet.get_node("Sprite").rotation = sprite.rotation
			bullet.set_modulate(Color(1, 0.2, 0.2))
			get_parent().add_child(bullet)
			fireTrack = -1
		
	if fireTrack != 0:
		fireTrack += fireRate
		if fireTrack >= fireCool:
			fireTrack = 0
	
	if vel.y > 0: vel.y -= DRAG
	elif vel.y < 0: vel.y += DRAG
	if vel.x > 0: vel.x -= DRAG
	elif vel.x < 0: vel.x += DRAG
	
	vel = vel.clamped(MAX_SPEED)
	position += vel * delta

func _on_Timer_timeout():
	
	angle = rng.randf_range(0, 2*PI)
