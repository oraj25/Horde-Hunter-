extends Area2D
@export var rotation_speed: float = 2.5 # How fast it spins (higher = faster)
@export var damage: int = 50             # How much damage it deals


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	rotation += rotation_speed * delta

func _on_body_entered(body):
	# 1. Check if the thing we hit is a zombie
	if body.is_in_group("players"):
		print("Sword hit player")
		# 2. Deal damage if the zombie has a "take_damage" function
		if body.has_method("take_damage"):
			body.take_damage(damage)
			AudioController.Sward()
		else:
			# Fallback: simple queue_free if no health system exists yet
			body.queue_free()
