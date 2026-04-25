extends Node
class_name PauseManager

var pause_menu: Control

func setup(target_pause_menu: Control) -> void:
	pause_menu = target_pause_menu
	if pause_menu:
		pause_menu.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	get_tree().paused = true
	if pause_menu:
		pause_menu.show()

func resume_game() -> void:
	get_tree().paused = false
	if pause_menu:
		pause_menu.hide()
