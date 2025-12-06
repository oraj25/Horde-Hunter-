extends Control


@onready var main_menu = load("res://mainmenu/main_menu.tscn") as PackedScene

func _on_retry_pressed() -> void:
	AudioController.Click()
	await get_tree().create_timer(0.1).timeout
	get_tree().reload_current_scene()

func set_score(value):
	$Panel/Score.text = "SCORE: " + str(value)

func set_high_score(value):
	$Panel/HighScore.text = "HIGH SCORE: " + str(value)



func _on_menu_pressed() -> void:
	AudioController.Click()
	AudioController.main()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_packed(main_menu)
