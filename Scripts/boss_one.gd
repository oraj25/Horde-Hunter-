extends CharacterBody2D


signal boss1_died(points)

const LOOT_SCENE = preload("res://Powerups/autogun_pickup.tscn")
@onready var player = get_node("/root/Game/Player")
@onready var health_bar = $ProgressBar
@export var points = 500

const MAX_HEALTH = 300.0
var health = MAX_HEALTH
var speed = 30.0

func _ready():
	add_to_group("bosses")
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
	AudioController.Zbossdead()
	boss1_died.emit(points)
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
