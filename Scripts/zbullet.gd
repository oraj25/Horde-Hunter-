extends Area2D
@export var damage : int = 10  
var traval_distance = 0

func _physics_process(delta):
	
	const SPEED = 250
	const RANGE = 1200
	
	var direction = Vector2.RIGHT.rotated(rotation)
	
	position += direction * SPEED * delta
	
	traval_distance += SPEED * delta
	
	if traval_distance > RANGE:
		queue_free()


func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage(damage)
