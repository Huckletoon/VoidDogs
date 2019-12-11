extends Node

var titleScene = preload("res://Title.tscn")
var worldScene = preload("res://World.tscn")
var bossScene = preload("res://BossWorld.tscn")
var loadScene = preload("res://LoadScreen.tscn")
var pauseMenu = preload("res://objects/PauseMenu.tscn")
var GameOver = preload("res://objects/GameOver.tscn")
var UpgradeScene = preload("res://objects/UpgradeMenu.tscn")
var OptionsMenu = preload("res://objects/OptionsMenu.tscn")

onready var musicBus = AudioServer.get_bus_index("Music")
onready var sfxBus = AudioServer.get_bus_index("SFX")

var difficulty
var level
var titleNode
var worldNode
var loadNode
var pauseNode
var gameOverNode
var upgradeNode
var optionsNode
var stage1Upgrade = 0
var stage2Upgrade = 0
var stage3Upgrade = 0
var stage4Upgrade = 0
var stage5Upgrade = 0

var musicVol = 0
var sfxVol = -5

var baseTarget = 40

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	AudioServer.set_bus_volume_db(musicBus, musicVol)
	AudioServer.set_bus_volume_db(sfxBus, sfxVol)
	level = "Title"
	difficulty = 1.0
	titleNode = titleScene.instance()
	add_child(titleNode)

func _process(delta):
	if Input.is_action_just_pressed("pl_start"):
		match level:
			"world", "boss":
				if !worldNode.get_node("Player").isDead: 
					if get_tree().paused: unpause()
					else: pause()
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

func options():
	optionsNode = OptionsMenu.instance()
	optionsNode.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(optionsNode)
	optionsNode.get_node("CenterContainer/VBoxContainer/MusicSlider").connect("value_changed", self, "musicSlider")
	optionsNode.get_node("CenterContainer/VBoxContainer/SFXSlider").connect("value_changed", self, "sfxSlider")
	optionsNode.get_node("CenterContainer/VBoxContainer/Back").connect("pressed", self, "optionsReturn")
	optionsNode.get_node("CenterContainer/VBoxContainer/MusicSlider").grab_focus()
	optionsNode.get_node("Cam").current = true
	pauseNode.get_node("Cam").current = false

func optionsReturn():
	pauseNode.get_node("Cam").current = true
	optionsNode.get_node("Cam").current = false
	optionsNode.queue_free()
	optionsNode = null
	pauseNode.get_node("CenterContainer/VBoxContainer/Resume").grab_focus()
	

func musicSlider(value):
	musicVol = value
	AudioServer.set_bus_volume_db(musicBus, musicVol)
	

func sfxSlider(value):
	sfxVol = value
	AudioServer.set_bus_volume_db(sfxBus, sfxVol)

func gameOver():
	match level:
		"world", "boss": 
			worldNode.queue_free()
			worldNode = null
	gameOverNode = GameOver.instance()
	add_child(gameOverNode)
	
func retry():
	gameOverNode.queue_free()
	gameOverNode = null
	if level == "world": startGame(1)
	elif level == "boss": startGame(2)

func startGame(arg):
	if arg == 0: remove_child(titleNode)
	if arg == 1 or arg == 0:
		startWorld()
	elif arg == 2:
		startBoss()

func startWorld():
	if worldNode == null:
		worldNode = worldScene.instance()
	add_child(worldNode)
	var director = worldNode.get_node("Director")
	director.enemyTarget = ceil(baseTarget * difficulty)
	director.allyTarget = max(40, ceil(40 / difficulty))
	director.MAX_SHIPS = min(ceil(100 * difficulty), 500)
	director.wait = max(0.2, 1.5/difficulty)
	director.initLevel()
	level = "world"

func startBoss():
	if worldNode == null:
		worldNode = bossScene.instance()
	add_child(worldNode)
	level = "boss"
	pass

func clearLevel():
	match level:
		"world":
			worldNode.queue_free()
			worldNode = null
			difficulty += 0.5
			goUpgrade()
		"boss":
			returnToTitle()
	

func goUpgrade():
	upgradeNode = UpgradeScene.instance()
	upgradeNode.setLevel(difficulty)
	add_child(upgradeNode)
	

func nextLevel():
	upgradeNode.queue_free()
	upgradeNode = null
	if difficulty != 4.0:
		startWorld()
	else:
		startBoss()

func returnToTitle():
	match level:
		"world", "boss":
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
