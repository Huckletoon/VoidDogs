extends AnimatedSprite

func _ready():
	play("boom")
	
func _physics_process(delta):
	if frame >= 9: queue_free()