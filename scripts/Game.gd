extends Node

var titleScene = preload("res://Title.tscn")
var worldScene = preload("res://World.tscn")
var loadScene = preload("res://LoadScreen.tscn")
var pauseMenu = preload("res://objects/PauseMenu.tscn")
var GameOver = preload("res://objects/GameOver.tscn")
var UpgradeScene = preload("res://objects/UpgradeMenu.tscn")

var difficulty
var level
var titleNode
var worldNode
var loadNode
var pauseNode
var gameOverNode
var upgradeNode
var stage1Upgrade = 0
var stage2Upgrade = 0
var stage3Upgrade = 0
var stage4Upgrade = 0
var stage5Upgrade = 0

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	level = "Title"
	difficulty = 1.0
	titleNode = titleScene.instance()
	add_child(titleNode)

func _process(delta):
	if Input.is_action_just_pressed("pl_start"):
		match level:
			"world":
				if !worldNode.get_node("Player").isDead: 
					if get_tree().paused: unpause()
					else: pause()
				else: 
					returnToTitle()
			"Title":
				startGame(0)

func pause():
	pauseNode = pauseMenu.instance()
	add_child(pauseNode)
	pauseNode.get_node("Cam").current = true
	worldNode.get_node("Player/Camera2D").current = false
	get_tree().paused = true

func unpause():
	pauseNode.get_node("Cam").current = false
	pauseNode.queue_free()
	pauseNode = null
	if worldNode != null: worldNode.get_node("Player/Camera2D").current = true
	get_tree().paused = false

func gameOver():
	match level:
		"world": 
			worldNode.queue_free()
			remove_child(worldNode)
			worldNode = null
	level = "gameOver"
	gameOverNode = GameOver.instance()
	add_child(gameOverNode)
	
func retry():
	match level:
		"world":
			gameOverNode.queue_free()
			remove_child(gameOverNode)
			gameOverNode = null
			startGame(1)

func startGame(arg):
	if arg == 0: remove_child(titleNode)
	if worldNode == null:
		worldNode = worldScene.instance()
	add_child(worldNode)
	var director = worldNode.get_node("Director")
	director.enemyTarget = ceil(75 * difficulty)
	director.allyTarget = max(40, ceil(40 / difficulty))
	director.MAX_SHIPS = min(ceil(100 * difficulty), 500)
	director.wait = max(0.2, 1.5/difficulty)
	director.initLevel()
	level = "world"

func clearLevel():
	match level:
		"world":
			worldNode.queue_free()
			worldNode = null
	difficulty += 0.5
	goUpgrade()

func goUpgrade():
	upgradeNode = UpgradeScene.instance()
	upgradeNode.setLevel(difficulty)
	add_child(upgradeNode)
	

func nextLevel():
	upgradeNode.queue_free()
	remove_child(upgradeNode)
	upgradeNode = null
	worldNode = worldScene.instance()
	var director = worldNode.get_node("Director")
	director.enemyTarget = ceil(75 * difficulty)
	director.allyTarget = max(40, ceil(40 / difficulty))
	director.MAX_SHIPS = min(ceil(100 * difficulty), 500)
	director.wait = max(0.2, 1.5/difficulty)
	add_child(worldNode)
	level = "world"

func returnToTitle():
	match level:
		"world":
			worldNode.queue_free()
			worldNode = null
		"gameOver":
			gameOverNode.queue_free()
			gameOverNode = null
	difficulty = 1
	stage1Upgrade = 0
	stage2Upgrade = 0
	stage3Upgrade = 0
	stage4Upgrade = 0
	stage5Upgrade = 0
	add_child(titleNode)
	titleNode.get_node("CenterContainer/VSplitContainer/VBoxContainer/Start").grab_focus()
	level = "Title"
	if pauseNode != null:
		unpause()
