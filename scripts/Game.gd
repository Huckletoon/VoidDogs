extends Node

var titleScene = preload("res://Title.tscn")
var worldScene = preload("res://World.tscn")

var level
var titleNode
var worldNode

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	level = "Title"
	titleNode = titleScene.instance()
	add_child(titleNode)

func _process(delta):
	if Input.is_action_just_pressed("pl_start"):
		match level:
			"world":
				if !worldNode.get_node("Player").isDead: 
					get_tree().paused = !get_tree().paused
				else: 
					returnToTitle()
					worldNode.queue_free()
					worldNode = null
			"Title":
				startGame()

func startGame():
	remove_child(titleNode)
	if worldNode == null:
		worldNode = worldScene.instance()
	add_child(worldNode)
	level = "world"

func returnToTitle():
	match level:
		"world":
			remove_child(worldNode)
	add_child(titleNode)
	level = "Title"
