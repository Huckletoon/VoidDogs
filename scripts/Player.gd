extends KinematicBody2D

class_name Player

var Bullet = preload("res://objects/Bullet.tscn")
var Particle = preload("res://objects/BoostParticle.tscn")
var Boom = preload("res://objects/BoomParticle.tscn")
var Stable = preload("res://objects/StableParticle.tscn")
var rng = RandomNumberGenerator.new()

var vel = Vector2(0,0)
var lookDir = Vector2()
var fire_rate = 150
var fire_track = 0
var fireHeat = 0
var burned = false
var maxHealth = 20
var health = maxHealth
var isDead = false

var shakeTrack = 0
var shakeX = 0
var shakeY = 0
var shakeCool = 20
var shakeMax = 64

var CAM_OFFSET_X = 400
var CAM_OFFSET_Y = 200

const MAX_SPEED = 1000
const ACCEL = 15
const DRAG = 1
const CAM_SMOOTH = 0.018
const FIRE_COOL = 1000
const MAX_HEAT = 800
const HEAT_COOL = 10
const BULLET_SPEED = 2000
const STABILIZER = 0.03

onready var sprite = get_node("Sprite")
onready var camera = get_node("Camera2D")
onready var radar = get_node("Radar")

func _ready():
	rng.randomize()
	get_tree().get_root().connect("size_changed", self, "resized")
	radar.maxHealth = maxHealth
	radar.health = health
	resized()

func is_type(type):
	return type == "Player"

func hit(damage):
	var boom = Boom.instance()
	boom.scale *= 0.5
	boom.position = position
	boom.position += Vector2(rng.randi_range(-16, 16), rng.randi_range(-16, 16))
	boom.rotate(rng.randf_range(0, 2*PI))
	get_parent().add_child(boom)
	health -= damage
	if health > 0:
		shakeTrack = 2
		radar.health = health
	elif radar.health == 1:
		radar.health = 0
		isDead = true

func resized():
	var wid = get_viewport_rect().size.x
	var hei = get_viewport_rect().size.y
	CAM_OFFSET_X = wid * 0.4
	CAM_OFFSET_Y = hei * 0.4
	radar.scrnWidth = wid
	radar.scrnHeight = hei

func offsetCam(x, y, weight):
	camera.offset = lerp(camera.offset, Vector2(x,y), weight)

func _physics_process(delta):
	
	radar.playerPos = position
	
	if !isDead:
		handleInput()
		vel = vel.clamped(MAX_SPEED)
	else:
		#boom
		if rng.randf() > 0.6:
			var boom = Boom.instance()
			boom.position = position
			boom.position += Vector2(rng.randi_range(-16, 16), rng.randi_range(-16, 16))
			boom.rotate(rng.randf_range(0, 2*PI))
			get_parent().add_child(boom)
		
	vel = move_and_slide(vel)
	shake()
	
	
func handleInput():
	#movement
	var yvar = Input.get_action_strength("pl_down") - Input.get_action_strength("pl_up")
	var xvar = Input.get_action_strength("pl_right") - Input.get_action_strength("pl_left")
	vel.y += ACCEL * yvar
	vel.x += ACCEL * xvar
	if vel.y > 0: vel.y -= DRAG
	elif vel.y < 0: vel.y += DRAG
	if vel.x > 0: vel.x -= DRAG
	elif vel.x < 0: vel.x += DRAG
	offsetCam(xvar * CAM_OFFSET_X, yvar * CAM_OFFSET_Y, CAM_SMOOTH)
	radar.camOff = camera.offset
	if yvar != 0 or xvar != 0: sprite.rotation = atan2(yvar, xvar) + PI/2
	lookDir = Vector2(sin(sprite.rotation), -cos(sprite.rotation))
	
	#particles
	if yvar != 0 or xvar != 0:
		if rng.randf() > 0.5:
			var particle = Particle.instance()
			particle.set_modulate(Color(0, 0.9, 0.9, 1))
			particle.position = position + lookDir * -12
			particle.position += Vector2(rng.randi_range(-5, 5), rng.randi_range(0,5))
			particle.vel = lookDir * -50
			particle.decay = 1.75
			particle.z_index = -1
			get_parent().add_child(particle)
	
	#Stabilize
	vel = lerp(vel, Vector2.ZERO, Input.get_action_strength("pl_stabilizer") * STABILIZER)
	if Input.get_action_strength("pl_stabilizer") > 0:
		if rng.randf() > 0.75:
			var part = Stable.instance()
			part.set_modulate(Color(0.2, 0.1, 0.8, 1))
			part.position = position
			part.position.x += rng.randi_range(-20, 20)
			part.position.y += rng.randi_range(-20, 20)
			part.decay = 1
			part.spin = 6
			part.z_index = -1
			get_parent().add_child(part)
			
	
	#fire
	if Input.is_action_pressed("pl_fire"):
		if fire_track == 0 and !burned:
			var bullet = Bullet.instance()
			bullet.position = position + lookDir*32
			bullet.velocity = lookDir * BULLET_SPEED
			bullet.get_node("Sprite").rotation = sprite.rotation
			get_parent().add_child(bullet)
			fire_track = -1
			fireHeat += fire_rate + 8
			if fireHeat >= MAX_HEAT:
				burned = true
	if fire_track != 0:
		fire_track += fire_rate
		if fire_track >= FIRE_COOL:
			fire_track = 0
	if fireHeat > 0:
		fireHeat = max(0, fireHeat - HEAT_COOL)
	elif burned:
		burned = false

func shake():
	if shakeTrack != 0:
		if shakeTrack % 4 == 0:
			shakeX = rng.randf_range(-1, 1) * shakeMax
			shakeY = rng.randf_range(-1, 1) * shakeMax
		shakeTrack += 1
		if shakeTrack >= shakeCool:
			shakeTrack = 0
			shakeX = 0
			shakeY = 0
		offsetCam(shakeX, shakeY, 0.1)
