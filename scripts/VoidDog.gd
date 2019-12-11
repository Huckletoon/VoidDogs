extends Area2D

class_name VoidDog

var Bullet = preload("res://objects/Bullet.tscn")
var Particle = preload("res://objects/BoostParticle.tscn")
var Boom = preload("res://objects/BoomParticle.tscn")
var Explode = preload("res://objects/Explode.tscn")
var rng = RandomNumberGenerator.new()

var vel = Vector2()
var player
var fireRate = 8
var fireTrack = 0
var fireCool = 1000
var bulletSpeed = 1500
var health = 20
var offense = true
var isDead = false

const MAX_SPEED = 1300
const ACCEL = 32
const DRAG = 4
const CLASS = "VoidDog"
const RANGE = 500

onready var sprite = get_node("Sprite")
onready var laser = get_node("Laser")
onready var director = get_parent()

func is_type(type):
	return type == CLASS

func get_type():
	return CLASS

func hit(damage):
	#hitSFX.play()
	var boom = Boom.instance()
	boom.scale *= 0.5
	boom.position = position
	boom.position += Vector2(rng.randi_range(-16, 16), rng.randi_range(-16, 16))
	boom.rotate(rng.randf_range(0, 2*PI))
	get_parent().add_child(boom)
	health -= damage
	if health <= 0:
		isDead = true
		player.complete()

# Start being offensive. Attempt to circle opponent and get shots in.
# After getting hit a couple of times, go defensive. Retreat in a pattern and fire from afar.
# Return to offensive after getting a hit or enough time has passed.
func _physics_process(delta):
	
	if isDead:
		#boom
		if rng.randf() > 0.6:
			var boom = Boom.instance()
			boom.position = position
			boom.position += Vector2(rng.randi_range(-16, 16), rng.randi_range(-16, 16))
			boom.rotate(rng.randf_range(0, 2*PI))
			get_parent().add_child(boom)
	elif offense:
		var target = player.position - self.position
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
			if fireTrack == 0:
				laser.play()
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
		#particles
		if rng.randf() > 0.5:
			var particle = Particle.instance()
			particle.set_modulate(Color(0.8, 0.3, 0.8, 1))
			var lookDir = Vector2(sin(sprite.rotation), -cos(sprite.rotation))
			particle.position = position + lookDir * -12
			particle.vel = lookDir * -50
			particle.decay = 4
			director.add_child(particle)
		
	vel = vel.clamped(MAX_SPEED)
	position += vel * delta
	