extends CharacterBody2D

signal died(points)

const Shiled_SCENE = preload("res://Powerups/shield_pickup.tscn")
const cooldown_SCENE = preload("res://Powerups/cooldown_pickup.tscn")
var S_drop_chance = 0.1
var C_drop_chance =0.1

@export var points = 30
@onready var player = get_node("/root/Game/Player")
@onready var health_bar = $ProgressBar

const MAX_HEALTH = 50.0
var Zhealth = MAX_HEALTH
var speed = 50.0
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
	print("Zombie took damage, health: ", Zhealth)
	health_bar.value = Zhealth
	if Zhealth <= 0:
		died.emit(points) 
		die()
		queue_free()
		
func take_small_damage (damage):
	Zhealth -= damage
	AudioController.Zdamage()
	health_bar.value = Zhealth
	if Zhealth <= 0:
		died.emit(points) 
		die()
		queue_free()
		


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
func start_groan_loop():
	while is_instance_valid(self):
		var random_wait = randf_range(5.0, 30)
		await get_tree().create_timer(random_wait).timeout
		if not is_instance_valid(self):
			break
		AudioController.Zboss()
