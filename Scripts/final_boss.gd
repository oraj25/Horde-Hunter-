extends CharacterBody2D

signal Final_boss_died(points)

const MINION_SCENE = preload("res://Sceans/small_minion.tscn")
const LOOT_SCENE = preload("res://Powerups/bot_pickup.tscn")

@onready var spawn_point = $spawn_point
@onready var player = get_node("/root/Game/Player")
@onready var health_bar = $ProgressBar
@export var points = 2000
@export var spread_angle : float = 60.0

const MAX_HEALTH = 1500.0
var health = MAX_HEALTH
var speed = 80.0

func _ready():
	add_to_group("final_boss")
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
	AudioController.Zbossbigdead()
	Final_boss_died.emit(points)
	 # Spawn the loot
	var loot = LOOT_SCENE.instantiate()
	loot.global_position = global_position
	get_parent().call_deferred("add_child", loot) # Add to the game world safely
	queue_free()

func spwan():
	var start_pos = global_position
	if spawn_point:
		start_pos = spawn_point.global_position
	for i in range(3):
		var new_minion = MINION_SCENE.instantiate()
		get_parent().call_deferred("add_child", new_minion)
		new_minion.global_position = start_pos
		var angle_multiplier = i - 1 
		var offset = deg_to_rad(spread_angle * angle_multiplier)
		new_minion.global_rotation = global_rotation + offset
		AudioController.minion()
		await get_tree().create_timer(0.5).timeout

func _on_spawner_timeout() -> void:
	spwan()
func start_groan_loop():
	while is_instance_valid(self):
		var random_wait = randf_range(5.0, 30)
		await get_tree().create_timer(random_wait).timeout
		if not is_instance_valid(self):
			break
		AudioController.Zboss()
