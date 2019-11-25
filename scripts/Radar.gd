extends Control

const PAD = 50
const RANGE = 1500
const ASSIST_RANGE = 200
const MIN_SIZE = 10
const UI_SWAY = 0.25
const BAR_BACK = Color(0.3, 0.3, 0.3, 1)

#Radar
var scrnWidth = 0
var scrnHeight = 0
var maxSize = 350
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

var dialogue = null

var dialogueNode = preload("res://objects/Dialogue.tscn")
onready var leftShoulder = preload("res://sprites/left_shoulder.png")
onready var hullSprite = preload("res://sprites/hull_plate.png")
onready var heatSprite = preload("res://sprites/heat_plate.png")
onready var font = preload("res://fonts/xolonium/xolonium.tres")
onready var cam = get_node("../Camera2D")
onready var director = get_node("../../Director")
onready var player = get_parent()

func _ready():
	pause_mode = PAUSE_MODE_PROCESS

func calcRadar():
	var x = -1 * (scrnWidth/2) + PAD + camOff.x
	var y = scrnHeight/2 - PAD - size.y + camOff.y
	maxSize = scrnWidth / 6
	pos = Vector2(x,y)
	if Input.is_action_just_pressed("pl_radar"):
		radarOn = !radarOn
		if radarOn: size = Vector2(maxSize, maxSize)
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
	
	#DEBUG
	var fpsX = scrnWidth * -0.5 + 16
	var fpsY = scrnHeight * -0.5 + 32
	fpsPos = Vector2(fpsX,fpsY) + camOff
	
	update()
	
	if director.objective and dialogue == null:
		dialogue = dialogueNode.instance()
		add_child(dialogue)


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
		draw_line(pointPool[n], pointPool[n+1], Color(0.1, 0.1, 0.1, 0.7), 1.5, true)

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
		var blipSize = 3
		if !radarOn: blipSize = 1
		var center = radarRect.position + radarRect.size/2
		for ship in director.ships:
			var diff = ship.position - playerPos
			var blipColor
			match ship.get_type():
				"Chaser": blipColor = Color.darkgoldenrod
				"Interceptor": blipColor = Color.darkmagenta
			drawBlip(diff, center, blipSize, blipColor)
			
		for ship in director.allies:
			var diff = ship.position - playerPos
			var blipColor
			match ship.get_type():
				"Ally": blipColor = Color.cyan
			drawBlip(diff, center, blipSize, blipColor)
			
		
		if director.allyCarrier != null:
			var diff = director.allyCarrier.position - playerPos
			drawBlip(diff, center, blipSize * 1.5, Color.yellow)
		

# Cohen-sutherland clipping
func drawBlip(diff, center, size, color):
	var posit
	var boundCode = 0
	if diff.x > RANGE: boundCode += 2
	elif diff.x < -RANGE: boundCode += 1
	if diff.y > RANGE: boundCode += 4
	elif diff.y < -RANGE: boundCode += 8
	match boundCode:
		0:
			var mag = diff.length()
			diff = diff.normalized()
			mag = (mag / RANGE) * (radarRect.size.x / 2)
			posit = center + diff * mag
		1:
			posit = center
			posit.x -= radarRect.size.x / 2
			posit.y += clamp(diff.y / RANGE * (radarRect.size.y / 2), -radarRect.size.y / 2, radarRect.size.y / 2)
		2:
			posit = center
			posit.x += radarRect.size.x / 2
			posit.y += clamp(diff.y / RANGE * (radarRect.size.y / 2), -radarRect.size.y / 2, radarRect.size.y / 2)
		4,5,6:
			posit = center
			posit.y += radarRect.size.y / 2
			posit.x += clamp(diff.x / RANGE * (radarRect.size.x / 2), -radarRect.size.x / 2, radarRect.size.x / 2)
		8,9,10:
			posit = center
			posit.y -= radarRect.size.y / 2
			posit.x += clamp(diff.x / RANGE * (radarRect.size.x / 2), -radarRect.size.x / 2, radarRect.size.x / 2)
	draw_circle(posit, size, color)

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
	draw_rect(healthBackRect, BAR_BACK, true)
	draw_rect(healthRect, Color.gray, true)
	draw_string(font, healthRect.position + Vector2(14, -12), health as String, Color(0,0,0,1))
	draw_texture(hullSprite, healthBackRect.position + Vector2(1, healthBackRect.size.y - 64))
	
	#Overheat
	var heatCol = lerp(coolCol, hotCol, float(player.fireHeat)/float(player.MAX_HEAT))
	if player.burned: heatCol = Color(0.3, 0.1, 0.3, 1)
	draw_rect(heatBackRect, BAR_BACK, true)
	draw_rect(heatRect, heatCol, true)
	draw_texture(heatSprite, heatBackRect.position + Vector2(1, heatBackRect.size.y - 64))
	
	#Death
	var black = Color.black
	black.a = deathAlpha
	if deathAlpha >= 1:
		get_tree().current_scene.gameOver()
	draw_rect(deathRect, black, true) 
	
	#DEBUG
	draw_string(font, fpsPos, "FPS: " + Engine.get_frames_per_second() as String)
	draw_string(font, fpsPos + Vector2(0, 26), "alpha v5")
	#draw_string(font, fpsPos + Vector2(0, 52), "Difficulty: " + director.get_parent().get_parent().difficulty as String)