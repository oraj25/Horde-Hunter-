extends CharacterBody2D

signal health_depleted
signal killed

@onready var invincibilityTimer = $Timer
@onready var shieldSprite = $Shield

var speed = 200.0     
var max_health = 100.0 
var damage_multiplier = 1.0
var rapid_fire_timer: Timer
var original_fire_delay: float = 1.5
var is_rapid_fire_active = false
var health = max_health
var dead = false
var coins = 0
var walls = 0


func _ready():
	if shieldSprite:
		shieldSprite.visible = false
	if invincibilityTimer:
		invincibilityTimer.one_shot = true 
		if not invincibilityTimer.timeout.is_connected(_on_invincibility_ended):
			invincibilityTimer.timeout.connect(_on_invincibility_ended)
			
	rapid_fire_timer = Timer.new()
	rapid_fire_timer.one_shot = true # Run once then stop
	rapid_fire_timer.timeout.connect(_on_rapid_fire_ended)
	add_child(rapid_fire_timer)
	#Hide and disable the Auto Gun at the start
	if has_node("AutoGun"):
		$AutoGun.visible = false
		$AutoGun.process_mode = Node.PROCESS_MODE_DISABLED
	if has_node("Firesword_Player"):
		$Firesword_Player.visible = false
		$Firesword_Player.process_mode = Node.PROCESS_MODE_DISABLED
	if has_node("Bots"):
		$Bots.visible = false
		$Bots.process_mode = Node.PROCESS_MODE_DISABLED

func _physics_process(delta):
	if dead:
		return
		
	var direction = Input.get_vector("left","right","up", "down")
	velocity = direction * speed
	
	const DAMAGE_RATE = 5.0
	var overlapping_zombies = %life.get_overlapping_bodies()
	
	if overlapping_zombies.size() > 0:
		if invincibilityTimer.is_stopped():
			health -= DAMAGE_RATE * overlapping_zombies.size() * delta
			AudioController.Pdamage()
			%ProgressBar.value = health
			if health <= 0.0:
				die()
	move_and_slide()

func take_damage (damage):
	if !invincibilityTimer.is_stopped():
		return
	health -= damage
	AudioController.Pdamage()
	%ProgressBar.value = health
	if health <= 0:
		die()
		return

func die():
	AudioController.Pdead()
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	health_depleted.emit()
	killed.emit()
	await get_tree().create_timer(5).timeout
	queue_free()

func enable_auto_gun():
	if has_node("AutoGun"):
		AudioController.newwepon()
		$AutoGun.visible = true
		$AutoGun.process_mode = Node.PROCESS_MODE_INHERIT
		print("Auto Gun Equipped!")

func enable_Firesword():
	if has_node("Firesword_Player"):
		AudioController.newwepon()
		$Firesword_Player.visible = true
		$Firesword_Player.process_mode = Node.PROCESS_MODE_INHERIT
		print("Firesword Equipped!")

func enable_Bots():
	if has_node("Bots"):
		AudioController.newwepon()
		$Bots.visible = true
		$Bots.process_mode = Node.PROCESS_MODE_INHERIT
		print("Bots Equipped!")

func collect_coin(amount):
	coins += amount
	AudioController.coin()
	var game_manager = get_parent()
	if "coins" in game_manager:
		game_manager.coins += amount
		print("Coin collected! Total: ", game_manager.coins)

func recover_health(heal_amount):
	AudioController.healthup()
	if health < max_health:
		health += heal_amount
		
		# Cap the health so it doesn't go over 100
		if health > max_health:
			health = max_health
			
		%ProgressBar.value = health
		print("Health recovered! Current health: ", health)
	else:
		print("Health full, potion wasted (or you can choose not to pick it up)")

func wall_count(amount):
	walls += amount
	AudioController.wallpickup()
	var game_manager = get_parent()
	if "walls_count" in game_manager:
		game_manager.walls_count += amount
		print("wall collected! Total: ", game_manager.walls_count)

func Shield_equip(shieldTime: float):
	AudioController.powerup()
	var time_left = invincibilityTimer.time_left
	invincibilityTimer.start(shieldTime + time_left)
	if shieldSprite:
		shieldSprite.visible = true
		print("Shield Equipped! Invincible for: ", shieldTime + time_left)

func _on_invincibility_ended():
	if shieldSprite:
		AudioController.powerdown()
		shieldSprite.visible = false
		print("Shield expired!")

func cooldown_equip(cooldown_reduction: float):
	if not has_node("Gun"): return
	
	# 1. If we are NOT already buffed, save the current speed
	if not is_rapid_fire_active:
		original_fire_delay = $Gun.fireDelay
		AudioController.powerup()
		# Apply the reduction
		$Gun.fireDelay -= cooldown_reduction
		if $Gun.fireDelay < 0.1: $Gun.fireDelay = 0.1 # Safety cap
		
		is_rapid_fire_active = true
		print("Rapid Fire Activated! Speed: ", $Gun.fireDelay)
	else:
		print("Rapid Fire Extended!")

	# 2. Start (or Restart) the 10-second timer
	rapid_fire_timer.start(10.0)

func _on_rapid_fire_ended():
	if has_node("Gun") and is_rapid_fire_active:
		# Restore the original speed
		AudioController.powerdown()
		$Gun.fireDelay = original_fire_delay
		is_rapid_fire_active = false
		print("Rapid Fire Ended. Speed reset to: ", original_fire_delay)
