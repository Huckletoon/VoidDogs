extends Area2D

class_name Bullet

var velocity = Vector2()
var life = 300
var tracker
var damage = 1
var team = 0

func is_type(type):
	return type == "Bullet"

func _physics_process(delta):
	position += velocity * delta
	life -= 1
	if life <= 0:
		self.queue_free()

func _on_Bullet_area_entered(area):
	match team:
		0:
			if area.is_type("Enemy") or area.is_type("Chaser"):
				tracker.currentKills += 1
				area.destroy()
				self.queue_free()
		1:
			pass


func _on_Bullet_body_entered(body):
	match team:
		0: pass
		1:
			if body.is_type("Player"):
				body.hit(damage)
				self.queue_free()
