extends Node2D

@onready var zombie_spawn_timer = $Timer
@onready var loot_spawn_timer = $lootTimer
@onready var next_wave_label = %nextwave
@onready var no_walls_message_label = %no_wall
@onready var Loot_message_label = %Loot_msg
@onready var permanent_boss = $bossOne
@onready var hud = $UILayer/MarginContainer/VBoxContainer/hud
@onready var gameOver = $UILayer/Game_over
@onready var Pause = $UILayer/pause
@onready var player = get_node("/root/Game/Player")
@onready var levelup = $UILayer/levalup

const LOOT_CRATE_SCENE = preload("res://Powerups/loot_crate.tscn")

const MINI_BOSS_SCENE = preload("res://Sceans/mini_boss_one.tscn")
var mini_boss_spawn_chance = 0.20
var normal_mini_boss_unlocked = false 

const FIRE_MINI_BOSS_SCENE = preload("res://Sceans/fireMINIboss.tscn")
var fire_mini_boss_unlocked = false

const Final_MINI_BOSS_SCENE = preload("res://Sceans/minni_final_boss.tscn")
@export var mini_boss_chance : float = 0.05
var Final_mini_boss_unlocked = false

var FireBoss = preload("res://Sceans/FireBoss.tscn") 
var fire_boss_spawned = false

var FinalBoss = preload("res://Sceans/final_boss.tscn") 
var Final_boss_spawned = false

# List of possible mobs to spawn. Start with the regular zombie.
var possible_mobs: Array[PackedScene] = [
	preload("res://Sceans/zombie.tscn") ]

var high_score
var score := 0:
	set(value):
		score = value
		hud.score = score

var coins := 0:
	set(value):
		coins = value
		hud.coins = coins
var walls_count := 0:
	set(value):
		walls_count = value
		hud.walls_count = walls_count

var current_wave_number = 1
# Zombie Spawning & Waves
var initial_spawn_time = 5.0
var min_spawn_time = 0.5
var spawn_time_decrease_rate = 0.05

var zombies_spawned_current_wave = 0 # Zombies spawned IN THE CURRENT WAVE
var zombies_defeated_current_wave = 0 # Zombies defeated IN THE CURRENT WAVE

var current_wave_spawn_total = 10 # Total zombies to spawn for the CURRENT wave
var current_zombie_limit = 10     # Max active zombies allowed at any given time (this is separate from total to spawn)

var wave_spawn_increase_amount = 10   # How much the total zombies to spawn increases per wave
var wave_limit_increase_amount = 5   # How much the active limit increases per wave
var max_total_zombie_limit = 100     # Absolute maximum active zombies
var max_wave_spawn_total = 100       # Absolute maximum zombies to spawn for a wave

# Zombie Health Progression
var zombie_health_increase_interval = 10 
var zombie_health_increase_amount = 0.5
var current_zombie_base_health = 5.0

# Zombie Speed Progression
var zombie_speed_increase_interval = 20 
var zombie_speed_increase_amount = 1.0
var initial_zombie_speed = 70.0
var max_zombie_speed = 300.0

# Wall Placement Variables
var wall_scene = preload("res://Sceans/wall.tscn") 
var is_placing_wall = false
var wall_preview_instance: StaticBody2D = null # To hold the ghost wall

func _ready():
	
	AudioController.gameBg()
	process_mode = Node.PROCESS_MODE_ALWAYS
	zombie_spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	loot_spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	if is_instance_valid(player):
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
	if Pause:
		Pause.visible = false
	
	
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file!=null:
		high_score = save_file.get_32()
	else:
		high_score = 0
		save_game()
	if FileAccess.file_exists("user://load_signal.flag"):
		print("Load signal found! Loading saved game...")
		load_game_data() 
		DirAccess.remove_absolute("user://load_signal.flag")
	else:
		zombie_spawn_timer.wait_time = initial_spawn_time
		zombie_spawn_timer.start()
		
		score = 0
		coins = 0
		walls_count = 0
		
		update_zombie_counter()
		
		print("Game Start: Wave 1. Current Spawn Total: ", current_wave_spawn_total, ", Active Limit: ", current_zombie_limit)
		next_wave_label.visible = false
		# Initial setup for wave 1
		zombies_spawned_current_wave = 0
		zombies_defeated_current_wave = 0
		
		if permanent_boss:
			if not permanent_boss.is_connected("boss1_died", Callable(self, "_on_boss1_died")):
				permanent_boss.connect("boss1_died", Callable(self, "_on_boss1_died"))
				print("Successfully connected boss1_died signal.") 
		else:
			print("WARNING: Could not find node 'bossOne' in the scene.")

func spwan():
	if !is_instance_valid(player):
		return # Stop processing if the player is gone
		
	# 1. SPECIAL WAVE LOGIC 
	if current_wave_number == 5:
		if not fire_boss_spawned:
			var boss = FireBoss.instantiate()
			# Random position 
			%PathFollow2D.progress_ratio = randf()
			boss.global_position = %PathFollow2D.global_position
			boss.add_to_group("boss_fire") # Ensure it doesn't count as a normal zombie limit
			add_child(boss)
			# Connect the signal
			if not boss.is_connected("bossFire_died", Callable(self, "_on_fire_boss_died")):
				boss.connect("bossFire_died", Callable(self, "_on_fire_boss_died"))
			fire_boss_spawned = true
			print("Fire Boss Spawned! Wave 5 Special.")
	if current_wave_number == 10:
		if not Final_boss_spawned:
			var boss = FinalBoss.instantiate()
			AudioController.bossMusic()
			# Random position 
			%LootPathFollow2D.progress_ratio = randf()
			boss.global_position = %LootPathFollow2D.global_position
			boss.add_to_group("final_boss") # Ensure it doesn't count as a normal zombie limit
			add_child(boss)
			# Connect the signal
			if not boss.is_connected("Final_boss_died", Callable(self, "_on_Final_boss_died")):
				boss.connect("Final_boss_died", Callable(self, "_on_Final_boss_died"))
			Final_boss_spawned = true
			print("final Boss Spawned! Wave 10 Special.")
		
	# 2. STANDARD SPAWN CHECKS
	var existing_zombies = get_tree().get_nodes_in_group("zombies")
	
	# Filter out permanent bosses from the active count
	var active_wave_mobs = []
	for node in existing_zombies:
		if not node.is_in_group("bosses"): 
			active_wave_mobs.append(node)
	# Only spawn if:1. We haven't spawned all zombies for the current wave yet 2. The number of active zombies is below the current active limit
	if zombies_spawned_current_wave >= current_wave_spawn_total or existing_zombies.size() >= current_zombie_limit:
		# If we've spawned all for the wave AND all active ones are dead, then it's time for next wave
		if zombies_spawned_current_wave >= current_wave_spawn_total and existing_zombies.size() == 0:
			print("All zombies for current wave spawned and defeated. Advancing to next wave.")
			_on_wave_completion()
		return # Exit the function, no spawn
	
	#3. SELECT MOB TYPE (Zombie vs. Mini Bosses)
	var mob_scene_to_spawn = preload("res://Sceans/zombie.tscn")
	# Roll dice for a mini-boss spawn
	if randf() < mini_boss_spawn_chance:
		
		var boss_selected = false
		#Priority 1: Final Mini Boss (Ultra Rare - 5%)
		if Final_mini_boss_unlocked and randf() < 0.05:
			mob_scene_to_spawn = Final_MINI_BOSS_SCENE
			boss_selected = true
			print("SUPER RARE! Final Mini Boss Selected")
			
		# 'elif' ensures we don't overwrite the final boss if it was already picked
		elif fire_mini_boss_unlocked and randf() < 0.20:
			mob_scene_to_spawn = FIRE_MINI_BOSS_SCENE
			boss_selected = true
			print("RARE! Fire Mini Boss Selected")
		 # Priority 3: Normal Mini Boss (Common/Default)
		elif normal_mini_boss_unlocked and randf() < 0.25:
			mob_scene_to_spawn = MINI_BOSS_SCENE
			boss_selected = true
			print("Standard Mini Boss Selected")
			# We should still pick *some* boss if possible, instead of reverting to a zombie.
		if not boss_selected:
			var available_backups = []
			if normal_mini_boss_unlocked: available_backups.append(MINI_BOSS_SCENE)
			if fire_mini_boss_unlocked: available_backups.append(FIRE_MINI_BOSS_SCENE)
			if Final_mini_boss_unlocked: available_backups.append(Final_MINI_BOSS_SCENE)
			if available_backups.size() > 0:
				mob_scene_to_spawn = available_backups.pick_random()
				print("Specific roll failed, picking random unlocked boss.")
	
	
	var new_mob = mob_scene_to_spawn.instantiate()
	new_mob.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	if "health" in new_mob:
		new_mob.health = current_zombie_base_health
	if "speed" in new_mob:
		new_mob.speed = initial_zombie_speed
		
	new_mob.add_to_group("zombies")
	add_child(new_mob)

	# Connect the zombie's 'died' signal to our handler
	if not new_mob.is_connected("died", Callable(self, "_on_zombie_died")):
		new_mob.connect("died", Callable(self, "_on_zombie_died"))

	zombies_spawned_current_wave += 1
	print("Spawned zombie ", zombies_spawned_current_wave, "/", current_wave_spawn_total)
	update_spawn_rate()
	update_zombie_health_and_speed_based_on_wave_progress()

func toggle_pause():
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	Pause.visible = is_paused


func _on_timer_timeout():
	spwan()

func _on_zombie_died(points):
	zombies_defeated_current_wave += 1
	score += points
	if score > high_score:
		high_score = score
	print(score)
	print("Zombie defeated! Total defeated this wave: ", zombies_defeated_current_wave, "/", current_wave_spawn_total)
	update_zombie_counter()
	# Check if all zombies for the current wave have been defeated
	# This also implicitly checks if all have been spawned first due to the spwan() logic
	if zombies_defeated_current_wave >= current_wave_spawn_total:
		var existing_zombies = get_tree().get_nodes_in_group("zombies")
		# Is the boss still alive?
		if current_wave_number == 5:
			var boss_alive = get_tree().get_nodes_in_group("boss_fire").size() > 0
			if boss_alive:
				return
		print("Wave Complete!")
		_on_wave_completion()

func update_zombie_counter():
	var remaining = current_wave_spawn_total - zombies_defeated_current_wave
	if remaining < 0: remaining = 0
	
	# Send this number to the HUD script
	if hud:
		hud.zombie_count = remaining

func advance_wave():
	print("Advancing to the next wave!")
	
	current_wave_number += 1
	
	# Reset counts for the new wave
	zombies_spawned_current_wave = 0
	zombies_defeated_current_wave = 0

	# Increase total zombies to spawn for the next wave
	current_wave_spawn_total += wave_spawn_increase_amount
	current_wave_spawn_total = min(current_wave_spawn_total, max_wave_spawn_total)

	# Increase active zombie limit for the next wave
	current_zombie_limit += wave_limit_increase_amount
	current_zombie_limit = min(current_zombie_limit, max_total_zombie_limit)
	
	update_zombie_counter()

	print("New Wave: Total to Spawn: ", current_wave_spawn_total, ", Active Limit: ", current_zombie_limit)


func update_spawn_rate():
	# This now just controls how fast new zombies are introduced within the current wave's total.
	var new_wait_time = zombie_spawn_timer.wait_time - spawn_time_decrease_rate
	zombie_spawn_timer.wait_time = max(new_wait_time, min_spawn_time)
	

func update_zombie_health_and_speed_based_on_wave_progress():
	# Health
	if zombies_spawned_current_wave % zombie_health_increase_interval == 0 and zombies_spawned_current_wave > 0:
		current_zombie_base_health += zombie_health_increase_amount
		print("Zombie base health increased to: ", current_zombie_base_health)

	# Speed
	if zombies_spawned_current_wave % zombie_speed_increase_interval == 0 and zombies_spawned_current_wave > 0:
		var new_speed = initial_zombie_speed + zombie_speed_increase_amount
		initial_zombie_speed = min(new_speed, max_zombie_speed)
		print("Zombie base speed increased to: ", initial_zombie_speed)

func _on_player_health_depleted():
	gameOver.set_score(score)
	gameOver.set_high_score(high_score)
	save_game()
	await get_tree().create_timer(1.5).timeout
	gameOver.visible = true
	

func _on_wave_completion():
	next_wave_label.visible = true
	print("Next Wave message displayed!")


func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		toggle_pause()
		return
	if get_tree().paused:
		return
	 # Toggle wall placement mode (press 'E' to toggle)
	if event.is_action_pressed("buid_mode"):
		
		# Case A: Currently OFF, trying to turn ON
		if not is_placing_wall:
			if walls_count > 0:
				is_placing_wall = true
				create_wall_preview()
				print("Wall placement mode ON")
			else:
				no_walls()
				print("Cannot enter build mode: No walls left!")
		
		# Case B: Currently ON, trying to turn OFF
		else:
			is_placing_wall = false
			remove_wall_preview()
			print("Wall placement mode OFF")
		
		return # Stop here so we don't accidentally place a wall in the same frame

	# 2. Handle Movement and Placement (Only if mode is ON)
	if is_placing_wall:
		if event is InputEventMouseMotion:
			update_wall_preview_position(event.position)
		elif event.is_action_pressed("place"): 
			place_wall()


func create_wall_preview():
	 # 1. Early exit if a preview already exists
	if wall_preview_instance != null:
		return
		
	# 2. Instantiate the wall scene
	var wall_base = wall_scene.instantiate()
	
	# 3. Early exit if instantiation failed
	if wall_base == null:
		print("Error: Could not instantiate wall_scene. Check path and scene file.")
		return
	# Assign the entire instantiated scene (StaticBody2D) as the preview instance.
	wall_preview_instance = wall_base
	
	# 4. Handle Sprite2D for transparency
	var sprite_node = wall_preview_instance.get_node_or_null("Sprite2D") 
	if sprite_node:
		sprite_node.modulate = Color(1, 1, 1, 0.5) # Set transparency for ghost effect
	else:
		print("Warning: Wall scene does not contain a 'Sprite2D' node as a child of its root. Preview transparency might not work.")
	# 5. Handle CollisionShape2D for disabling collisions during preview
	# Ensure wall_preview_instance is indeed a StaticBody2D before trying to access its collision.
	if wall_preview_instance is StaticBody2D: # This check is important as wall_preview_instance is Node2D type
		var collision_shape = (wall_preview_instance as StaticBody2D).get_node_or_null("CollisionShape2D")
		if collision_shape:
			collision_shape.disabled = true
		else:
			print("Warning: Wall preview (StaticBody2D) does not contain a 'CollisionShape2D' node as a child of its root. Collision might not be disabled.")
	else:
		# This error means the wall_scene root is not a StaticBody2D, which is unexpected for a wall.
		print("Error: Instantiated wall scene root is not a StaticBody2D. Cannot disable collision.")

	 # 6. Final steps: Add to scene and set owner
	add_child(wall_preview_instance) # Add the root node of the instantiated wall scene
	wall_preview_instance.owner = self # Set owner for proper tree management
	print("Wall preview created.") # Confirmation message for successful creation


func update_wall_preview_position(mouse_position: Vector2):
	if wall_preview_instance:
		var world_mouse_position = get_global_mouse_position()
		wall_preview_instance.global_position = world_mouse_position


func remove_wall_preview():
	if wall_preview_instance:
		wall_preview_instance.queue_free()
		wall_preview_instance = null


func place_wall():
	# Safety check
	if walls_count <= 0:
		return
	
	if wall_preview_instance: # Only place if a preview exists
		var new_wall = wall_scene.instantiate()
		AudioController.wallPlace()
		print("Preview global_position before placement: ", wall_preview_instance.global_position)
		new_wall.global_position = wall_preview_instance.global_position
		print("New wall global_position after assignment: ", new_wall.global_position)
		new_wall.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(new_wall)
		walls_count -= 1
		print("Wall placed! Walls remaining: ", walls_count)
		print("Wall placed at: ", new_wall.global_position)
		if walls_count <= 0:
			is_placing_wall = false
			remove_wall_preview()
			no_walls()
			print("Out of walls! Turning off build mode.")
func _on_boss1_died(points):
	print("Main Boss defeated! Unlocking Mini-Boss for wave spawns.")
	score += points
	if score > high_score:
		high_score = score
	# FIX: Set the flag to true, enabling the mini-boss chance in spwan()
	normal_mini_boss_unlocked = true
		
func _on_fire_boss_died(points):
	print("Fire Boss Defeated! Wave 5 Complete.")
	score += points
	if score > high_score:
		high_score = score
	fire_mini_boss_unlocked = true 
	print("Fire Mini Bosses are now unlocked for future waves!")
	_on_wave_completion()

func _on_Final_boss_died(points):
	print("Final Boss Defeated! Wave 11 Complete.")
	AudioController.start()
	score += points
	if score > high_score:
		high_score = score
	Final_mini_boss_unlocked = true 
	print("Final Mini Bosses are now unlocked for future waves!")
	_on_wave_completion()

func save_game():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(high_score)

func _on_save_pressed() -> void:
	print("saved game...")
	AudioController.save()
	save_game_data()
func no_walls():
	no_walls_message_label.visible = true
	await get_tree().create_timer(2).timeout
	no_walls_message_label.visible = false

func _on_ready_pressed():
	AudioController.Click()
	next_wave_label.visible = false
	print("Ready button pressed. Hiding 'Next Wave' message.")
	advance_wave()
	print("Ready button pressed. Advancing to next wave.")
	zombie_spawn_timer.start()
	print("Ready button pressed. Zombie spawning resumed.")

func _on_levelupbutton_pressed():
	AudioController.Click()
	if levelup.visible:
		levelup.visible = false
	else:
		levelup.visible = true

func _on_loot_timer_timeout() -> void:
	loot_spawn_timer.wait_time = randf_range(45.0, 60.0)
	loot_spawn_timer.start()
	loot_spwaner()

func loot_spwaner():
	var current_crates = get_tree().get_nodes_in_group("loot")
	if current_crates.size() >= 3:
		print("Max loot crates reached (3). Skipping spawn.")
		return
	var new_create = LOOT_CRATE_SCENE.instantiate()
	%LootPathFollow2D.progress_ratio = randf()
	new_create.global_position = %LootPathFollow2D.global_position
	print("loot spwaned")
	new_create.add_to_group("loot")
	add_child(new_create)
	loot_notice()

	# Connect the zombie's 'died' signal to our handler
	if not new_create.is_connected("died", Callable(self, "_on_Create_open")):
		new_create.connect("died", Callable(self, "_on_Create_open"))
func _on_Create_open(points):
	score += points
	if score > high_score:
		high_score = score
	
func loot_notice():
	Loot_message_label.visible = true
	await get_tree().create_timer(2).timeout
	Loot_message_label.visible = false

# --- SAVE FUNCTION ---
func save_game_data():
	# Gather all data into a dictionary
	var save_dict = {
		"game": {
			 "score": score,
			"high_score": high_score,
			"coins": coins,
			"walls": walls_count,
			"wave": current_wave_number
		},
		"wave_logic": {
			"spawned": zombies_spawned_current_wave,
			"defeated": zombies_defeated_current_wave,
			"total_spawn": current_wave_spawn_total,
			"limit": current_zombie_limit
		},
		"difficulty": {
			"base_health": current_zombie_base_health,
			"speed": initial_zombie_speed
		},
		"unlocks": {
			"normal_mini": normal_mini_boss_unlocked,
			"fire_mini": fire_mini_boss_unlocked,
			"final_mini": Final_mini_boss_unlocked,
			"fire_boss_done": fire_boss_spawned,
			"final_boss_done": Final_boss_spawned
		},
		"player": {
			"health": player.health,
			"max_health": player.max_health,
			"damage_mult": player.damage_multiplier,
			"speed": player.speed,
			"pos_x": player.global_position.x,
			"pos_y": player.global_position.y
		}
	}
	 # Save to JSON file
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	file.store_string(json_string)
	file.close()
	 # Also update high score file separately just in case
	var hs_file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	hs_file.store_32(high_score)
	print("Game Saved Successfully!")

func load_game_data():
	if not FileAccess.file_exists("user://savegame.json"):
		print("No save file found!")
		return
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json_string = file.get_as_text()
	var data = JSON.parse_string(json_string)
	if data:
		# Restore Game Variables
		score = data["game"]["score"]
		high_score = data["game"]["high_score"]
		coins = data["game"]["coins"]
		walls_count = data["game"]["walls"]
		current_wave_number = data["game"]["wave"]
		 # Restore Wave Logic
		zombies_spawned_current_wave = data["wave_logic"]["spawned"]
		zombies_defeated_current_wave = data["wave_logic"]["defeated"]
		current_wave_spawn_total = data["wave_logic"]["total_spawn"]
		current_zombie_limit = data["wave_logic"]["limit"]
		# Restore Difficulty
		current_zombie_base_health = data["difficulty"]["base_health"]
		initial_zombie_speed = data["difficulty"]["speed"]
		# Restore Unlocks
		normal_mini_boss_unlocked = data["unlocks"]["normal_mini"]
		fire_mini_boss_unlocked = data["unlocks"]["fire_mini"]
		Final_mini_boss_unlocked = data["unlocks"]["final_mini"]
		fire_boss_spawned = data["unlocks"]["fire_boss_done"]
		Final_boss_spawned = data["unlocks"]["final_boss_done"]
		# Restore Player
		if is_instance_valid(player):
			player.health = data["player"]["health"]
			player.max_health = data["player"]["max_health"]
			player.damage_multiplier = data["player"]["damage_mult"]
			player.speed = data["player"]["speed"]
			player.global_position = Vector2(data["player"]["pos_x"], data["player"]["pos_y"])
			 # Update Player Health Bar
			player.get_node("%ProgressBar").max_value = player.max_health
			player.get_node("%ProgressBar").value = player.health
		# Restore HUD
		hud.score = score
		hud.coins = coins
		hud.walls_count = walls_count
		update_zombie_counter()
		print("Save Loaded!")
