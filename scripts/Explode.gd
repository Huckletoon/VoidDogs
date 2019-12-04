extends AudioStreamPlayer2D

func _physics_process(delta):
	if !playing: queue_free()