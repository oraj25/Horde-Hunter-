extends CharacterBody2D

signal died(points)

const COIN_SCENE = preload("res://Powerups/coin_pickup.tscn")
var drop_chance = 0.4
const LIFE_SCENE = preload("res://Powerups/life_pickup.tscn")
var life_drop_chance = 0.1
const WALL_SCENE = preload("res://Powerups/wall_pickup.tscn")
var wall_drop_chance = 0.1


@export var points = 10
@onready var player = get_node("/root/Game/Player")
var health = 5.0
var speed = 70.0


func _ready():
	add_to_group("zombies")
	start_groan_loop()


func _physics_process(delta):
	if !is_instance_valid(player):
		velocity = Vector2.ZERO
		return # Stop processing if the player is gone
	var derection = global_position.direction_to(player.global_position)
	look_at(player.global_position)

	velocity = derection * speed
	move_and_slide()



func take_damage (damage):
	health -= damage
	AudioController.Zdamage()
	# print("Zombie took damage, health: ", health)
	if health <= 0:
		died.emit(points) # <--- Emit the signal when health drops to 0 or below
		die()
		
func take_small_damage (damage):
	health -= damage
	AudioController.Zdamage()
	if health <= 0:
		died.emit(points) 
		die()
func die():
	AudioController.Zdead()
	# 2. Roll the dice to see if a coin drops
	if randf() < drop_chance:
		var coin = COIN_SCENE.instantiate()
		coin.global_position = global_position
		get_parent().call_deferred("add_child", coin)
	if randf() < life_drop_chance:
		var life = LIFE_SCENE.instantiate()
		life.global_position = global_position
		# Offset slightly so it doesn't stack perfectly on the coin
		life.global_position.x += 10 
		get_parent().call_deferred("add_child", life)
	if randf() < wall_drop_chance:
		var wall = WALL_SCENE.instantiate()
		wall.global_position = global_position
		# Offset slightly so it doesn't stack perfectly on the coin
		wall.global_position.x -= 10 
		get_parent().call_deferred("add_child", wall)
	queue_free()
func start_groan_loop():
	while is_instance_valid(self):
		var random_wait = randf_range(5.0, 30.0)
		await get_tree().create_timer(random_wait).timeout
		if not is_instance_valid(self):
			break
		AudioController.Zidol()
