extends Area2D

var traval_distance = 0
@export var damage : int = 2.5
func _physics_process(delta):
	
	const SPEED = 600
	const RANGE = 1200
	
	var direction = Vector2.RIGHT.rotated(rotation)
	
	position += direction * SPEED * delta
	
	traval_distance += SPEED * delta
	
	if traval_distance > RANGE:
		queue_free()


func _on_body_entered(body):
	queue_free()
	if body.has_method("take_small_damage"):
		var final_damage = damage
		# 2. Find the player to get their upgrade stat
		var player = get_tree().get_first_node_in_group("player")
		if not player:
			player = get_node_or_null("/root/Game/Player")
		# 3. Apply the multiplier if player exists
		if player and "damage_multiplier" in player:
			final_damage = int(damage + player.damage_multiplier)
		# 4. Deal the calculated damage
		body.take_small_damage(final_damage)
