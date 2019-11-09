extends Node

class_name Director

var rng = RandomNumberGenerator.new()
var ships = []
var Enemy = preload("res://objects/Enemy.tscn")
var Chaser = preload("res://objects/Chaser.tscn")

const MAX_SHIPS = 100

onready var timer = get_node("Timer")
onready var player = get_node("../Player")

func _ready():
	timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	timer.wait_time = 2.5
	for i in range(10):
		spawnEnemy()
	timer.start()
	rng.randomize()

func spawnEnemy():
	if ships.size() < MAX_SHIPS:
		var enemy
		match rng.randi_range(0,2):
			1: enemy = Enemy.instance()
			_: enemy = Chaser.instance()
		
		enemy.player = player
		var relative = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
		while relative.x > -0.2 and relative.x < 0.2:
			relative.x = rng.randf_range(-1, 1)
		while relative.y > -0.2 and relative.y < 0.2:
			relative.y = rng.randf_range(-1, 1)
		enemy.position = player.position + Vector2(relative.x * rng.randi_range(1000,6000), relative.y * rng.randi_range(1000,6000))
		ships.append(enemy)
		add_child(enemy)

func _on_Timer_timeout():
	spawnEnemy()
