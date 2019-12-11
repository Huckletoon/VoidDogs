extends Area2D

onready var director = get_parent()

func is_type(type):
	return type == "AllyCarrier"

func _on_AllyCarrier_body_entered(body):
	if body.is_type("Player") and director.objective:
		director.clearLevel()


func _on_AllyCarrier_area_entered(area):
	if (area.is_type("Ally") or area.is_type("AllyArmored")) and area.retreating:
		director.allies.erase(area)
		area.queue_free()
