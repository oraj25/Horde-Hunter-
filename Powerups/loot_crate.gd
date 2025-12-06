extends CharacterBody2D

signal died(points)

const COIN_SCENE = preload("res://Powerups/coin_pickup.tscn")
const LIFE_SCENE = preload("res://Powerups/life_pickup.tscn")
const WALL_SCENE = preload("res://Powerups/wall_pickup.tscn")
const SHIELD_SCENE = preload("res://Powerups/shield_pickup.tscn")
const COOLDOWN_SCENE = preload("res://Powerups/cooldown_pickup.tscn")

var coin_weight = 40.0
var life_weight = 20.0
var wall_weight = 15.0
var shield_weight = 10.0
var cooldown_weight = 10.0


@export var points = 200
@onready var player = get_node("/root/Game/Player")
var health = 50.0

func _ready():
	add_to_group("loot")


func _physics_process(delta):
	if !is_instance_valid(player):
		return # Stop processing if the player is gone

func take_damage (damage):
	health -= damage
	AudioController.Zdead()
	if health <= 0:
		die()
func take_small_damage (damage):
	health -= damage
	AudioController.Zdead()
	if health <= 0:
		die()
func die():
	AudioController.loot()
	for i in range(5):
		spawn_random_item()
	died.emit(points) 
	queue_free()

func spawn_random_item():
	# 1. Create the Loot Table (Scene + Weight)
	var loot_table = [
		{"scene": COIN_SCENE, "weight": coin_weight},
		{"scene": LIFE_SCENE, "weight": life_weight},
		{"scene": WALL_SCENE, "weight": wall_weight},
		{"scene": SHIELD_SCENE, "weight": shield_weight},
		{"scene": COOLDOWN_SCENE, "weight": cooldown_weight}
	]
	
	# 2. Calculate Total Weight
	var total_weight = 0.0
	for item in loot_table:
		total_weight += item["weight"]
	
	# 3. Roll the Dice (0 to Total Weight)
	var roll = randf_range(0.0, total_weight)
	
	# 4. Find which item won
	var selected_scene = COIN_SCENE # Default fallback
	var current_sum = 0.0
	
	for item in loot_table:
		current_sum += item["weight"]
		if roll <= current_sum:
			selected_scene = item["scene"]
			break
	
	# 5. Instantiate the Winner
	var drop = selected_scene.instantiate()
	drop.global_position = global_position
	
	# Add a random offset so they explode outwards slightly
	var offset = Vector2(randf_range(-40, 50), randf_range(-50, 40))
	drop.global_position += offset
	
	get_parent().call_deferred("add_child", drop)
