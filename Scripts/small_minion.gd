extends CharacterBody2D

const SPEED = 150 
@export var damage : int = 15
var health = 5

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("players")
	
	if player:
		look_at(player.global_position)
		position += transform.x * SPEED * delta

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("players"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			die()

func _ready():
	add_to_group("small_minion")

func take_damage (damage):
	health -= damage
	# print("Zombie took damage, health: ", health)
	if health <= 0:
		die()
		
func take_small_damage (damage):
	health -= damage
	if health <= 0:
		die()

func die():
	AudioController.Zdead()
	queue_free()
