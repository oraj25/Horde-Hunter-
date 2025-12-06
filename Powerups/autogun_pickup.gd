extends Area2D

@export var rotation_speed: float = 2.0 

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	rotation += rotation_speed * delta
func _on_body_entered(body):
	# Check if the body is the Player
	if body.name == "Player" or body.is_in_group("player"):
		if body.has_method("enable_auto_gun"):
			body.enable_auto_gun()
			queue_free() # Delete the item from the ground
