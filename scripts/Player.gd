extends KinematicBody2D

class_name Player

var Bullet = preload("res://objects/Bullet.tscn")
var rng = RandomNumberGenerator.new()

var vel = Vector2(0,0)
var lookDir = Vector2()
var fire_rate = 40
var fire_track = 0
var maxHealth = 10
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
	shakeTrack = 2
	health -= damage
	if health > 0:
		radar.health = health
	elif radar.health == 1:
		radar.health = 0
		isDead = true
	elif isDead:
		shakeTrack = shakeCool - 3

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
	
	radar.playerPos = self.position
	
	if !isDead:
		handleInput()
		vel = vel.clamped(MAX_SPEED)
	else:
		offsetCam(0,0,0.3)
		if Input.is_action_just_pressed("pl_start"):
			get_tree().change_scene("res://Title.tscn")
		
	vel = move_and_slide(vel)
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
	
	#Stabilize
	vel = lerp(vel, Vector2.ZERO, Input.get_action_strength("pl_stabilizer") * STABILIZER)
	
	#fire
	lookDir = Vector2(sin(sprite.rotation), -cos(sprite.rotation))
	
	if Input.is_action_pressed("pl_fire"):
		if fire_track == 0:
			var bullet = Bullet.instance()
			bullet.tracker = radar
			bullet.position = position + lookDir*32
			bullet.velocity = lookDir * BULLET_SPEED
			bullet.get_node("Sprite").rotation = sprite.rotation
			get_parent().add_child(bullet)
			fire_track = -1
	
	if fire_track != 0:
		fire_track += fire_rate
		if fire_track >= FIRE_COOL:
			fire_track = 0