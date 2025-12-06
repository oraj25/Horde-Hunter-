extends MarginContainer
signal start_next_wave
signal save_game_pressed


func _ready():
	pass

func _on_start_next_wave():
	start_next_wave.emit()


func _on_save_game_pressed():
	save_game_pressed.emit()
