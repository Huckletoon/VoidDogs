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
var AllyCarrier = preload("res://objects/AllyCarrier.tscn")
var EnemyCarrier = preload("res://objects/EnemyCarrier.tscn")

var enemyTarget = 75
var allyTarget = 40
var enemiesKilled = 0
var alliesKilled = 0
var wait = 1
var objective = false

var MAX_SHIPS = 100

onready var timer = get_node("Timer")
onready var player = get_node("../Player")
onready var oppNode = get_node("OppGroup")
onready var allyNode = get_node("AllyGroup")

func _ready():
	timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = wait
	rng.randomize()
	allyCarrier = AllyCarrier.instance()
	allyCarrier.position = Vector2(rng.randi_range(-7000, -5000), rng.randi_range(-2000, 2000))
	add_child(allyCarrier)
	player.position = allyCarrier.position + Vector2(100, 0)
	enemyCarrier = EnemyCarrier.instance()
	enemyCarrier.position = Vector2(rng.randi_range(5000, 7000), rng.randi_range(-2000, 2000))
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
	get_parent().get_parent().clearLevel()


func spawnEnemy():
	if ships.size() < MAX_SHIPS:
		var enemy
		match rng.randi_range(1,4):
			0: enemy = Enemy.instance()
			1,2,3: enemy = Chaser.instance()
			4: enemy = Interceptor.instance()
		
		enemy.player = player
		enemy.position = enemyCarrier.position + Vector2(rng.randi_range(-300, -30), rng.randi_range(-200, 200))
		ships.append(enemy)
		oppNode.add_child(enemy)

func spawnAlly():
	if allies.size() < MAX_SHIPS:
		var ally
		match rng.randi_range(0,1):
			_: ally = Ally.instance()
		ally.position = allyCarrier.position + Vector2(rng.randi_range(30,200), rng.randi_range(-200, 200))
		allies.append(ally)
		allyNode.add_child(ally)
		

func _on_Timer_timeout():
	spawnEnemy()
	if ships.size() < 8: 
		for i in range(10): spawnEnemy()
	if allies.size() < min(10, allyTarget - alliesKilled): spawnAlly()
