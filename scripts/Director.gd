extends Node

class_name Director

var rng = RandomNumberGenerator.new()
var ships = []
var allies = []
var Ally = preload("res://objects/Ally.tscn")
var Enemy = preload("res://objects/Enemy.tscn")
var Chaser = preload("res://objects/Chaser.tscn")
var Interceptor = preload("res://objects/Interceptor.tscn")

var enemyTarget = 100
var allyTarget = 40
var enemiesKilled = 0
var alliesKilled = 0

const MAX_SHIPS = 100

onready var timer = get_node("Timer")
onready var player = get_node("../Player")
onready var oppNode = get_node("OppGroup")
onready var allyNode = get_node("AllyGroup")

func _ready():
	timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = 1.5
	for i in range(40):
		if i%4 == 0:
			spawnAlly()
		else:
			spawnEnemy()
	timer.start()
	rng.randomize()

func spawnEnemy():
	if ships.size() < MAX_SHIPS:
		var enemy
		match rng.randi_range(1,4):
			0: enemy = Enemy.instance()
			1,2,3: enemy = Chaser.instance()
			4: enemy = Interceptor.instance()
		
		enemy.player = player
		var relative = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
		while relative.x > -0.2 and relative.x < 0.2:
			relative.x = rng.randf_range(-1, 1)
		while relative.y > -0.2 and relative.y < 0.2:
			relative.y = rng.randf_range(-1, 1)
		enemy.position = player.position + Vector2(relative.x * rng.randi_range(1000,6000), relative.y * rng.randi_range(1000,6000))
		ships.append(enemy)
		oppNode.add_child(enemy)

func spawnAlly():
	if allies.size() < MAX_SHIPS:
		var ally
		match rng.randi_range(0,1):
			_: ally = Ally.instance()
		var relative = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
		while relative.x > -0.2 and relative.x < 0.2:
			relative.x = rng.randf_range(-1, 1)
		while relative.y > -0.2 and relative.y < 0.2:
			relative.y = rng.randf_range(-1, 1)
		ally.position = player.position + Vector2(relative.x * rng.randi_range(1000,6000), relative.y * rng.randi_range(1000,6000))
		allies.append(ally)
		allyNode.add_child(ally)
		

func _on_Timer_timeout():
	spawnEnemy()
	if ships.size() < 8: 
		for i in range(10): spawnEnemy()
	if allies.size() < min(10, allyTarget - alliesKilled): spawnAlly()
