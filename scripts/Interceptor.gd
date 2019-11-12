extends Area2D

class_name Interceptor

var Bullet = preload("res://objects/Bullet.tscn")
#var font = preload("res://fonts/xolonium/xolonium.tres")
var rng = RandomNumberGenerator.new()

var vel = Vector2()
var player
var fireRate = 8
var fireTrack = 0
var fireCool = 1000
var bulletSpeed = 1500
var targetIndex = -1
var targetShip

const MAX_SPEED = 1300
const ACCEL = 32
const DRAG = 4
const CLASS = "Interceptor"
const RANGE = 500
const ORBIT = 300

onready var sprite = get_node("Sprite")
onready var director = get_parent().get_parent()

func is_type(type):
	return type == CLASS
	
func get_type():
	return CLASS

func destroy():
	director.enemiesKilled += 1
	director.ships.erase(self)
	self.queue_free()

func getTarget():
	if (rng.randi_range(0, director.allies.size()) < 4) or director.allies.size() < 1:
		targetIndex = -1 #player
		targetShip = player
	else:
		targetIndex = rng.randi_range(0, director.allies.size() - 1)
		targetShip = director.allies[targetIndex]

func _ready():
	rng.randomize()
	getTarget()

func _physics_process(delta):
	
	if targetShip == null or targetShip.is_queued_for_deletion():
		getTarget()
	
	var target = targetShip.position - self.position
	var targetDist = target.length()
	var farLead = target + player.vel * delta
	var farLeadNorm = farLead.normalized()
	var lead = target + player.vel.normalized() * (player.vel.length() / player.MAX_SPEED * 100)
	var leadNorm = lead.normalized()
	if targetDist > RANGE:
		sprite.rotation = atan2(farLeadNorm.y, farLeadNorm.x) + PI/2
		vel += ACCEL * farLead.normalized()
	else:
		sprite.rotation = atan2(leadNorm.y, leadNorm.x) + PI/2
		if targetDist > ORBIT: vel += ACCEL * leadNorm
		if fireTrack == 0:
			var bullet = Bullet.instance()
			bullet.team = 1
			bullet.position = position + leadNorm*32
			bullet.velocity = leadNorm * bulletSpeed
			bullet.get_node("Sprite").rotation = sprite.rotation
			bullet.set_modulate(Color(0.8, 0, 1))
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
	