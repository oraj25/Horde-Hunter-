extends CharacterBody2D

signal died(points)
@export var points = 35
@onready var player = get_node("/root/Game/Player")

var Zhealth = 80.0
var speed = 60.0

const Shiled_SCENE = preload("res://Powerups/shield_pickup.tscn")
const cooldown_SCENE = preload("res://Powerups/cooldown_pickup.tscn")
const COIN_SCENE = preload("res://Powerups/coin_pickup.tscn")
var drop_chance = 0.4
var S_drop_chance = 0.1
var C_drop_chance =0.1

func _ready():
	add_to_group("zombies")
	start_groan_loop()


func _physics_process(delta):
	if !is_instance_valid(player):
		velocity = Vector2.ZERO
		return # Stop processing if the player is gone
	var derection = global_position.direction_to(player.global_position)
	velocity = derection * speed
	move_and_slide()


func take_damage (damage):
	Zhealth -= damage
	AudioController.Zdamage()
	# print("Zombie took damage, health: ", health)
	if Zhealth <= 0:
		died.emit(points) 
		queue_free()
		die()
		
func take_small_damage (damage):
	Zhealth -= damage
	AudioController.Zdamage()
	if Zhealth <= 0:
		died.emit(points) 
		queue_free()
		die()

func die():
	AudioController.Zbossdead()
	if randf() < S_drop_chance:
		var Shiled = Shiled_SCENE.instantiate()
		Shiled.global_position = global_position
		get_parent().call_deferred("add_child", Shiled)
	
	if randf() < C_drop_chance:
		var cooldown = cooldown_SCENE.instantiate()
		cooldown.global_position = global_position
		get_parent().call_deferred("add_child", cooldown)
	if randf() < drop_chance:
		var coin = COIN_SCENE.instantiate()
		coin.global_position = global_position
		get_parent().call_deferred("add_child", coin)
func start_groan_loop():
	while is_instance_valid(self):
		var random_wait = randf_range(5.0, 30)
		await get_tree().create_timer(random_wait).timeout
		if not is_instance_valid(self):
			break
		AudioController.Zboss()
