extends Node

class_name Director

var rng = RandomNumberGenerator.new()
var ships = []
var allies = []
var allyCarrier = null
var enemyCarrier = null
var Ally = preload("res://objects/Ally.tscn")
var Enemy = preload("res://objects/Enemy.tscn")
var Chaser = preload("res://objects/Chaser.tscn")
var Interceptor = preload("res://objects/Interceptor.tscn")
var Armored = preload("res://objects/Armored.tscn")
var AllyArmored = preload("res://objects/AllyArmored.tscn")
var AllyCarrier = preload("res://objects/AllyCarrier.tscn")
var EnemyCarrier = preload("res://objects/EnemyCarrier.tscn")

var enemyTarget = 35#DEBUG75
var allyTarget = 40
var enemiesKilled = 0
var alliesKilled = 0
var wait = 1
var objective = false
var carrierRadius

var MAX_SHIPS = 100
var RADIUS = 7000

onready var timer = get_node("Timer")
onready var player = get_node("../Player")
onready var oppNode = get_node("OppGroup")
onready var allyNode = get_node("AllyGroup")

func _ready():
	timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = wait
	rng.randomize()
	carrierRadius = rng.randf_range(0.7, 1) * RADIUS
	var angle = rng.randf_range(0, 2*PI)
	allyCarrier = AllyCarrier.instance()
	allyCarrier.position = Vector2(sin(angle), cos(angle)) * carrierRadius
	add_child(allyCarrier)
	player.position = allyCarrier.position + Vector2(100, 0)
	angle += PI
	enemyCarrier = EnemyCarrier.instance()
	enemyCarrier.position = Vector2(sin(angle), cos(angle)) * carrierRadius
	initLevel()
	

func initLevel():
	for i in range(10):
		if i%3 == 0:
			spawnAlly()
		else:
			spawnEnemy()
	timer.start()

func _physics_process(delta):
	if alliesKilled >= allyTarget:
		pass
	if enemiesKilled >= enemyTarget:
		objective = true

func clearLevel():
	get_tree().current_scene.clearLevel()


func spawnEnemy():
	var typeRange = 4
	#Temporary
	if get_tree().current_scene.difficulty > 1.4: typeRange += 1
	
	if ships.size() < MAX_SHIPS:
		var enemy
		match rng.randi_range(1,typeRange):
			0: enemy = Enemy.instance()
			1,2,3: enemy = Chaser.instance()
			4: enemy = Interceptor.instance()
			5: enemy = Armored.instance()
		
		enemy.player = player
		enemy.position = enemyCarrier.position + Vector2(rng.randi_range(-300, -30), rng.randi_range(-200, 200))
		ships.append(enemy)
		oppNode.add_child(enemy)

func spawnAlly():
	var typeRange = 1
	#Temporary
	if get_tree().current_scene.difficulty > 1.4: typeRange += 2
	
	if allies.size() < MAX_SHIPS:
		var ally
		match rng.randi_range(typeRange - 1, typeRange):
			0,1: ally = Ally.instance()
			2,3: ally = AllyArmored.instance()
			
		ally.position = allyCarrier.position + Vector2(rng.randi_range(30,200), rng.randi_range(-200, 200))
		allies.append(ally)
		allyNode.add_child(ally)
		

func _on_Timer_timeout():
	spawnEnemy()
	if ships.size() < 8: 
		for i in range(10): spawnEnemy()
	if allies.size() < min(10, allyTarget - alliesKilled): spawnAlly()
