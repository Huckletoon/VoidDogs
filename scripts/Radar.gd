extends Control

const PAD = 50
const RANGE = 2500
const ASSIST_RANGE = 200
const MAX_SIZE = 350
const MIN_SIZE = 10
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
var barWidth = 300
var barPad = 8
var barBackRect = Rect2(barPos, barSize)
var allyPos = Vector2.ZERO
var allySize = Vector2.ZERO
var allyRect = Rect2(allyPos, allySize)

#Health
var maxHealth = 0
var health = 0
var healthPos = Vector2.ZERO
var healthSize = Vector2.ZERO
var healthRect = Rect2(healthPos, healthSize)
var healthHeight = 300
var healthWidth = 50
var healthPad = 8
var healthBackRect = Rect2(healthPos, healthSize)
var deathAlpha = 0
var deathRect = Rect2(Vector2(-3000, -3000), Vector2(6000, 6000))

#Overheat
var heatPos = Vector2.ZERO
var heatSize = Vector2.ZERO
var heatRect = Rect2(heatPos, heatSize)
var heatHeight = healthHeight
var heatPad = healthPad
var heatBackRect = Rect2(heatPos, heatSize)
var coolCol = Color(0, 0.3, 0.9, 1)
var hotCol = Color(0.9, 0.3, 0, 1)

#DEBUG
var fpsPos = Vector2.ZERO
var physStep = 0

onready var leftShoulder = preload("res://sprites/left_shoulder.png")
onready var font = preload("res://fonts/xolonium/xolonium.tres")
onready var cam = get_node("../Camera2D")
onready var director = get_node("../../Director")
onready var player = get_parent()

func _ready():
	pause_mode = PAUSE_MODE_PROCESS

func calcRadar():
	var x = -1 * (scrnWidth/2) + PAD + camOff.x
	var y = scrnHeight/2 - PAD - size.y + camOff.y
	pos = Vector2(x,y)
	if Input.is_action_just_pressed("pl_radar"):
		radarOn = !radarOn
		if radarOn: size = Vector2(MAX_SIZE, MAX_SIZE)
		else: size = Vector2(MIN_SIZE, MIN_SIZE)
	radarRect.position = lerp(radarRect.position, pos, UI_SWAY)
	radarRect.size = lerp(radarRect.size, size, UI_SWAY)

func calcObjective():
	var barX = barPad * 2.5 + camOff.x
	var barY = -1 * (scrnHeight/2) + 24 + camOff.y
	barPos = Vector2(barX, barY)
	barSize = Vector2(barWidth - min(barWidth as float * (director.enemiesKilled as float/director.enemyTarget as float)
		, barWidth), 32)
	barRect.position = lerp(barRect.position, barPos, UI_SWAY)
	barRect.size = barSize
	
	allyPos = barPos
	allyPos.x -= (barWidth + barPad * 6)
	allySize = Vector2(barWidth - min(barWidth as float * (director.alliesKilled as float/director.allyTarget as float)
		, barWidth), 32)
	allyRect.position = lerp(allyRect.position, allyPos, UI_SWAY)
	allyRect.size = allySize
	
	barPos -= Vector2(barPad, barPad)
	barSize = Vector2(barWidth + 2*barPad, barSize.y + 2*barPad)
	barBackRect.position = lerp(barBackRect.position, barPos, UI_SWAY)
	barBackRect.size = barSize
	
	

func calcHealth():
	var healthX = scrnWidth/2 - healthPad - 90 + camOff.x
	var healthY = scrnHeight/2 - healthPad - 12 + camOff.y
	healthPos = Vector2(healthX, healthY)
	healthSize = Vector2(healthWidth,-healthHeight + healthHeight * (1-(float(health)/float(maxHealth))))
	healthRect.position = lerp(healthRect.position, healthPos, UI_SWAY)
	healthRect.size = healthSize
	healthPos += Vector2(-healthPad, healthPad)
	healthSize = Vector2(healthSize.x + 2*healthPad, -(healthHeight + 2*barPad))
	healthBackRect.position = lerp(healthBackRect.position, healthPos, UI_SWAY)
	healthBackRect.size = healthSize 
	if health <= 0 and deathAlpha < 1:
		deathAlpha += 0.01

func calcHeat():
	var heatX = scrnWidth/2 - heatPad*4 - 90 - healthSize.x + camOff.x
	var heatY = scrnHeight/2 - heatPad - 12 + camOff.y
	heatPos = Vector2(heatX, heatY)
	heatSize = Vector2(healthWidth, -heatHeight + heatHeight * max(0,(1-(float(player.fireHeat)/float(player.MAX_HEAT)))))
	heatRect.position = lerp(heatRect.position, heatPos, UI_SWAY)
	heatRect.size = heatSize
	heatPos += Vector2(-heatPad, heatPad)
	heatSize = Vector2(heatSize.x + 2*heatPad, -(heatHeight + 2*heatPad))
	heatBackRect.position = lerp(heatBackRect.position, heatPos, UI_SWAY)
	heatBackRect.size = heatSize
	

func _physics_process(delta):
	#Radar
	calcRadar()
	
	#Kill Tracker
	calcObjective()
	
	#Health
	calcHealth()
	
	calcHeat()
	
	#Pause
	if Input.is_action_just_pressed("pl_start"): get_tree().paused = !get_tree().paused
	
	#DEBUG
	var fpsX = scrnWidth * -0.5 + 16
	var fpsY = scrnHeight * -0.5 + 32
	fpsPos = Vector2(fpsX,fpsY) + camOff
	physStep = delta
	
	update()

#TODO
func draw_outline(center):
	var points = 48
	var pointPool = PoolVector2Array()
	var chunk = 2*PI / float(points)
	var widthMod = scrnWidth / (4*RANGE) * radarRect.size.x
	var heightMod = scrnHeight / (4*RANGE) * radarRect.size.y
	
	for i in range(points+1):
		var point = i * chunk
		pointPool.push_back(center + Vector2(cos(point) * widthMod, sin(point) * heightMod))
		
		
	for n in range(points):
		draw_line(pointPool[n], pointPool[n+1], Color(0.1, 0.1, 0.1, 0.7))

func drawRadar():
	var screen = Color.azure
	screen.a = 0.3
	draw_rect(radarRect, screen, true)
	draw_outline(radarRect.position + radarRect.size/2)
	if radarOn: draw_circle(radarRect.position + radarRect.size/2, 5, Color.blue)
	else: 
		draw_circle(radarRect.position + radarRect.size/2, 2, Color.blue)
		draw_texture(leftShoulder, radarRect.position + Vector2(radarRect.size.x, -radarRect.size.y - leftShoulder.get_height()/2))
	if director != null:
		var center = radarRect.position + radarRect.size/2
		for ship in director.ships:
			var diff = ship.position - playerPos
			if !(diff.x > RANGE or diff.x < -RANGE or diff.y > RANGE or diff.y < -RANGE):
				var mag = diff.length()
				diff = diff.normalized()
				mag = (mag / RANGE) * (radarRect.size.x/2)
				var posit = center + diff * mag
				
				var blipSize = 4
				if !radarOn: blipSize = 1
				
				if ship.is_type("Enemy"): draw_circle(posit, blipSize, Color.darkgoldenrod)
				elif ship.is_type("Chaser"): draw_circle(posit, blipSize, Color.firebrick)
				elif ship.is_type("Interceptor"): draw_circle(posit, blipSize, Color.darkmagenta)
		for ship in director.allies:
			var diff = ship.position - playerPos
			if !(diff.x > RANGE or diff.x < -RANGE or diff.y > RANGE or diff.y < -RANGE):
				var mag = diff.length()
				diff = diff.normalized()
				mag = (mag / RANGE) * (radarRect.size.x/2)
				var posit = center + diff * mag
				
				var blipSize = 4
				if !radarOn: blipSize = 1
				if ship.is_type("Ally"): draw_circle( posit, blipSize, Color.cyan)

func drawObjective():
	draw_rect(barBackRect, Color.darkgray, true)
	draw_rect(barRect, Color.darkgoldenrod, true)
	
	draw_rect(Rect2(barBackRect.position - Vector2(barWidth + barPad * 6, 0), barBackRect.size), Color.darkgray, true)
	draw_rect(allyRect, Color.darkblue, true)
	
	var textPos = barRect.position
	textPos.x += barPad
	textPos.y += barRect.size.y - barPad
	if director.enemiesKilled >= director.enemyTarget:
		draw_string(font, textPos , "Mission Complete!")
	else:
		draw_string(font, textPos, "Targets left: " + (director.enemyTarget - director.enemiesKilled) as String)
	
	textPos.x -= (barWidth + barPad * 5)
	if director.alliesKilled >= director.allyTarget:
		draw_string(font, textPos, "Ally forces defeated!")
	else:
		draw_string(font, textPos, "Allies remaining: " + (director.allyTarget - director.alliesKilled) as String)



func _draw():
	#Radar
	drawRadar()
	
	#Target Bar
	drawObjective()
	
	#Health
	var back = Color(0.3, 0.3, 0.3, 1)
	draw_rect(healthBackRect, back, true)
	draw_rect(healthRect, Color.gray, true)
	draw_string(font, healthRect.position + Vector2(14, -12), health as String, Color(0,0,0,1))
	
	#Overheat
	var heatCol = lerp(coolCol, hotCol, float(player.fireHeat)/float(player.MAX_HEAT))
	if player.burned: heatCol = Color(0.3, 0.1, 0.3, 1)
	draw_rect(heatBackRect, back, true)
	draw_rect(heatRect, heatCol, true)
	
	#Death
	var black = Color.black
	black.a = deathAlpha
	draw_rect(deathRect, black, true) 
	if health <= 0:
		draw_string(font,Vector2(-50, -64), "Game Over")
		draw_string(font, Vector2(-54, -32), "Press Start")
		
	#Pause
	if get_tree().paused:
		draw_string(font,Vector2(-50, -64), "Paused")
	
	#DEBUG
	draw_string(font, fpsPos, "FPS: " + Engine.get_frames_per_second() as String)