extends Control

var game_controller: Node

func setup(target_game_controller: Node) -> void:
	game_controller = target_game_controller

func _on_save_button_pressed() -> void:
	if game_controller != null:
		game_controller.save_game()

func _on_load_button_pressed() -> void:
	if game_controller != null:
		game_controller.load_game()
