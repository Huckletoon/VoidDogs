extends Control

const PAD = 50
const RANGE = 6000
const MAX_SIZE = 350
const MIN_SIZE = 70
const UI_SWAY = 0.25

#Radar
var scrnWidth = 0
var scrnHeight = 0
var camOff = Vector2(0,0)
var pos = Vector2(0,0)
var size = Vector2(MIN_SIZE, MIN_SIZE)
var radarRect = Rect2(pos, size)
var playerPos = Vector2(0,0)
var radarOn = false

#Kill Tracker
var barPos = Vector2.ZERO
var barSize = Vector2.ZERO
var barRect = Rect2(barPos, barSize)
var targetKills = 50
var currentKills = 0
var barWidth = 300
var barPad = 8
var barBackRect = Rect2(barPos, barSize)

#Health
var maxHealth = 0
var health = 0
var healthPos = Vector2.ZERO
var healthSize = Vector2.ZERO
var healthRect = Rect2(healthPos, healthSize)
var healthHeight = 300
var healthPad = 8
var healthBackRect = Rect2(healthPos, healthSize)
var deathAlpha = 0
var deathRect = Rect2(Vector2(-3000, -3000), Vector2(6000, 6000))

#DEBUG
var fpsPos = Vector2.ZERO
var physStep = 0

onready var font = preload("res://fonts/xolonium/xolonium.tres")
onready var cam = get_node("../Camera2D")
onready var director = get_node("../../Director")


func _physics_process(delta):
	#Radar
	var x = -1 * (scrnWidth/2) + PAD + camOff.x
	var y = scrnHeight/2 - PAD - size.y + camOff.y
	
	pos = Vector2(x,y)
	
	if Input.is_action_just_pressed("pl_radar"):
		radarOn = !radarOn
		if radarOn: size = Vector2(MAX_SIZE, MAX_SIZE)
		else: size = Vector2(MIN_SIZE, MIN_SIZE)
	
	radarRect.position = lerp(radarRect.position, pos, UI_SWAY)
	radarRect.size = lerp(radarRect.size, size, UI_SWAY)
	
	#Kill Tracker
	var barX = -1 * (barWidth / 2) + camOff.x
	var barY = -1 * (scrnHeight/2) + 24 + camOff.y
	barPos = Vector2(barX, barY)
	barSize = Vector2(barWidth - min(barWidth as float * (currentKills as float/targetKills as float), barWidth), 32)
	barRect.position = lerp(barRect.position, barPos, UI_SWAY)
	barRect.size = barSize
	
	barPos -= Vector2(barPad, barPad)
	barSize = Vector2(barWidth + 2*barPad, barSize.y + 2*barPad)
	barBackRect.position = lerp(barBackRect.position, barPos, UI_SWAY)
	barBackRect.size = barSize
	
	#Health
	var healthX = scrnWidth/2 - healthPad - 90 + camOff.x
	var healthY = scrnHeight/2 - healthPad - 12 + camOff.y
	healthPos = Vector2(healthX, healthY)
	healthSize = Vector2(64,-healthHeight + healthHeight * (1-(float(health)/float(maxHealth))))
	healthRect.position = lerp(healthRect.position, healthPos, UI_SWAY)
	healthRect.size = healthSize
	
	healthPos += Vector2(-healthPad, healthPad)
	healthSize = Vector2(healthSize.x + 2*healthPad, -(healthHeight + 2*barPad))
	healthBackRect.position = lerp(healthBackRect.position, healthPos, UI_SWAY)
	healthBackRect.size = healthSize 
	
	if health <= 0 and deathAlpha < 1:
		deathAlpha += 0.01
	
	#DEBUG
	var fpsX = scrnWidth * -0.5 + 16
	var fpsY = scrnHeight * -0.5 + 32
	fpsPos = Vector2(fpsX,fpsY) + camOff
	physStep = delta
	
	update()

func _draw():
	#Radar
	var screen = Color.azure
	screen.a = 0.3
	draw_rect(radarRect, screen, true)
	if radarOn: draw_circle(radarRect.position + radarRect.size/2, 5, Color.blue)
	else: draw_circle(radarRect.position + radarRect.size/2, 2, Color.blue)
	if director != null:
		for ship in director.ships:
			var center = radarRect.position + radarRect.size/2
			var diff = ship.position - playerPos
			if !(diff.x > RANGE or diff.x < -RANGE or diff.y > RANGE or diff.y < -RANGE):
				var mag = diff.length()
				diff = diff.normalized()
				mag = (mag / RANGE) * (radarRect.size.x/2)
				var posit = center + diff * mag
				
				if radarOn: 
					if ship.is_type("Enemy"): draw_circle(posit, 4, Color.darkgoldenrod)
					elif ship.is_type("Chaser"): draw_circle(posit, 4, Color.firebrick)
				else: 
					if ship.is_type("Enemy"): draw_circle(posit, 1, Color.darkgoldenrod)
					elif ship.is_type("Chaser"): draw_circle(posit, 1, Color.firebrick)
				
	#Target Bar
	draw_rect(barBackRect, Color.darkgray, true)
	draw_rect(barRect, Color.darkgoldenrod, true)
	
	if currentKills >= targetKills:
		var textPos = barRect.position
		textPos.x += barPad
		textPos.y += barRect.size.y - barPad
		draw_string(font, textPos , "Mission Complete")
	
	#Health
	var back = Color(0.3, 0.3, 0.3, 1)
	draw_rect(healthBackRect, back, true)
	draw_rect(healthRect, Color.gray, true)
	
	#Death
	var black = Color.black
	black.a = deathAlpha
	draw_rect(deathRect, black, true) 
	if health <= 0:
		draw_string(font,Vector2(-50, -64), "Game Over")
		draw_string(font, Vector2(-54, -32), "Press Start")
	
	#DEBUG
	draw_string(font, fpsPos, "FPS: " + Engine.get_frames_per_second() as String)