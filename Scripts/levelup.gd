extends Control

# Prices
var speed_cost = 5
var health_cost = 10
var damage_cost = 3

# References
@onready var game_manager = get_node("/root/Game") # Adjust path if needed
@onready var player = get_node("/root/Game/Player")

func _on_speed_button_pressed():
	
	if game_manager.coins >= speed_cost:
		AudioController.levelup()
		game_manager.coins -= speed_cost
		
		player.speed += 10
		print("Speed Upgraded! New Speed: ", player.speed)
	else:
		print("Not enough coins for Speed!")

func _on_health_button_pressed():
	
	if game_manager.coins >= health_cost:
		game_manager.coins -= health_cost
		AudioController.levelup()
		# Increase Max Health AND Heal the player fully
		player.max_health += 10
		player.health = player.max_health
		player.get_node("%ProgressBar").max_value = player.max_health
		player.get_node("%ProgressBar").value = player.health  # Update bar size
		print("Health Upgraded! New Max: ", player.max_health)
	else:
		print("Not enough coins for Health!")

func _on_damage_button_pressed():
	
	if game_manager.coins >= damage_cost:
		game_manager.coins -= damage_cost
		AudioController.levelup()
		# Increase damage multiplier (e.g. +10% damage)
		player.damage_multiplier += 2
		print("Damage Upgraded! New Multiplier: ", player.damage_multiplier)
	else:
		print("Not enough coins for Damage!")

# Close the menu button
func _on_close_button_pressed():
	AudioController.Click()
	visible = false
