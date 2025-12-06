extends CharacterBody2D

signal bossFire_died(points)

const LOOT_SCENE = preload("res://Powerups/firesword_pickup.tscn")
@onready var player = get_node("/root/Game/Player")
@onready var health_bar = $ProgressBar
@export var points = 1000

const MAX_HEALTH = 600.0
var health = MAX_HEALTH
var speed = 60.0

func _ready():
	add_to_group("boss_fire")
	start_groan_loop()
	if is_instance_valid(health_bar):
		health_bar.max_value = MAX_HEALTH
		health_bar.value = health

func _physics_process(delta):
	if !is_instance_valid(player):
		velocity = Vector2.ZERO
		return # Stop processing if the player is gone
	var derection = global_position.direction_to(player.global_position)

	velocity = derection * speed
	move_and_slide()


func take_damage (damage):
	health -= damage
	AudioController.Zdamage()
	print("Zombie took damage, health: ", health)
	health_bar.value = health
	if health <= 0:
		die()
		
func take_small_damage (damage):
	health -= damage
	AudioController.Zdamage()
	health_bar.value = health
	if health <= 0:
		die()

func die():
	bossFire_died.emit(points)
	AudioController.Zbossdead()
	 # Spawn the loot
	var loot = LOOT_SCENE.instantiate()
	loot.global_position = global_position
	get_parent().call_deferred("add_child", loot) # Add to the game world safely
	queue_free()
func start_groan_loop():
	while is_instance_valid(self):
		var random_wait = randf_range(5.0, 30)
		await get_tree().create_timer(random_wait).timeout
		if not is_instance_valid(self):
			break
		AudioController.Zboss()
