extends Area2D

class_name AllyArmored

var Particle = preload("res://objects/BoostParticle.tscn")
var Bullet = preload("res://objects/Bullet.tscn")
var Boom = preload("res://objects/BoomParticle.tscn")
var Explode = preload("res://objects/Explode.tscn")

var rng = RandomNumberGenerator.new()
var vel = Vector2()
var angle = 0
var fireRate = 10
var fireTrack = 0
var fireCool = 900
var bulletSpeed = 2000
var target = 0
var targetShip
var currentHealth = MAX_HEALTH

const MAX_SPEED = 900
const ACCEL = 22
const DRAG = 1
const RANGE = 700
const ORBIT = 400
const CLASS = "AllyArmored"
const MAX_HEALTH = 3

onready var sprite = get_node("Sprite")
onready var laser = get_node("Laser")
onready var director = get_parent().get_parent()

func is_type(type):
	return type == CLASS

func get_type():
	return CLASS

func hit(damage):
	var boom = Boom.instance()
	boom.scale *= 0.5
	boom.position = position
	boom.position += Vector2(rng.randi_range(-16, 16), rng.randi_range(-16, 16))
	boom.rotate(rng.randf_range(0, 2*PI))
	get_parent().add_child(boom)
	currentHealth -= damage
	if currentHealth <= 0:
		destroy()

func destroy():
	director.alliesKilled += 1
	director.allies.erase(self)
	var explode = Explode.instance()
	explode.position = position
	explode.pitch_scale += rng.randf_range(-0.3, 0.1)
	director.add_child(explode)
	for x in range(rng.randi_range(1,3)):
		var boom = Boom.instance()
		boom.position = position
		boom.position += Vector2(rng.randi_range(-16, 16), rng.randi_range(-16, 16))
		boom.rotate(rng.randf_range(0, 2*PI))
		get_parent().add_child(boom)
	self.queue_free()

func getTarget():
	if director.ships.size() < 1:
		target = -1
		targetShip = null
	else:
		target = rng.randi_range(0, director.ships.size() - 1)
		targetShip = director.ships[target]

func _ready():
	rng.randomize()
	angle = rng.randf_range(0, 2*PI)
	getTarget()

func _physics_process(delta):
	
	if targetShip == null or targetShip.is_queued_for_deletion() or rng.randf() > 0.96:
		getTarget()
	
	if targetShip != null:
		var diff = targetShip.position - self.position
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
				laser.play()
				var bullet = Bullet.instance()
				bullet.team = -1
				bullet.position = position + diff*32
				bullet.velocity = diff * bulletSpeed
				bullet.get_node("Sprite").rotation = sprite.rotation
				bullet.set_modulate(Color(0.2, 0.2, 1))
				director.add_child(bullet)
				fireTrack = -1
			
	
	#particles
	if rng.randf() > 0.5:
		var particle = Particle.instance()
		particle.set_modulate(Color(0, 0.4, 0.9, 1))
		var lookDir = Vector2(sin(sprite.rotation), -cos(sprite.rotation))
		particle.position = position + lookDir * -12
		particle.vel = lookDir * -50
		particle.decay = 4
		director.add_child(particle)
	
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