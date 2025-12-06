extends Control

@onready var score = $Score:
	set(value):
		score.text = "Score: " + str(value) 

@onready var coins = $Coins:
	set(value):
		coins.text = "     " + str(value)
@onready var walls_count = $walls_count:
	set(value):
		walls_count.text = "     " + str(value)
@onready var zombie_count =$zombie_count:
	set(value):
		zombie_count.text = "     " + str(value)
