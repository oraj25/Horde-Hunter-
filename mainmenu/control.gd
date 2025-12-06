extends Control

@onready var mainmenue = preload("res://mainmenu/main_menu.tscn") as PackedScene


func _on_return_pressed() -> void:
	AudioController.Click()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_packed(mainmenue)
