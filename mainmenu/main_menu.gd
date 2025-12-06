class_name MainMenu
extends Control

# References to your buttons
@onready var Start_Button = $MarginContainer/HBoxContainer/VBoxContainer/Start as Button
@onready var Exit_Button = $MarginContainer/HBoxContainer/VBoxContainer/Exit as Button

# Reference to your game scene
@onready var start_level = preload("res://Sceans/game.tscn") as PackedScene
@onready var controls = load("res://mainmenu/control.tscn") as PackedScene

# Define your desired colors
const NORMAL_COLOR := Color("ffffff") 
const START_HOVER_COLOR := Color("00ff00") 
const EXIT_HOVER_COLOR := Color("ff0000") 
const PRESSED_COLOR := Color("ffff00")

func _ready():
	
	# Connect button signals
	Start_Button.pressed.connect(on_Start_pressed) 
	Exit_Button.pressed.connect(on_exit_pressed)   
	# Apply theme overrides for Start button colors
	Start_Button.add_theme_color_override("font_color", NORMAL_COLOR)
	Start_Button.add_theme_color_override("font_hover_color", START_HOVER_COLOR)
	Start_Button.add_theme_color_override("font_pressed_color", PRESSED_COLOR)


	# Apply theme overrides for Exit button colors
	Exit_Button.add_theme_color_override("font_color", NORMAL_COLOR)
	Exit_Button.add_theme_color_override("font_hover_color", EXIT_HOVER_COLOR)
	Exit_Button.add_theme_color_override("font_pressed_color", PRESSED_COLOR)
	pass 

func on_Start_pressed() -> void:
	$click.play()
	await get_tree().create_timer(0.1).timeout
	AudioController.start()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_packed(start_level)

func on_exit_pressed() -> void:
	$click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()


func _on_Continue_pressed() -> void:
	$click.play()
	await get_tree().create_timer(0.2).timeout
	var flag = FileAccess.open("user://load_signal.flag", FileAccess.WRITE)
	flag.store_string("load")
	flag.close()
	get_tree().change_scene_to_packed(start_level)


func _on_controls_pressed() -> void:
	$click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_packed(controls)
