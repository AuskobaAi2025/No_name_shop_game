extends Node


const SAVE_PATH := "res://Saves/save_data.dat"
const SAVE_VERSION := 1

func save_game(data: Dictionary) -> bool:
	var wrapped_data := {
		"version": SAVE_VERSION,
		"payload": data
	}

	var json_text := JSON.stringify(wrapped_data)
	var encoded_text := Marshalls.utf8_to_base64(json_text)

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(encoded_text)
	file.close()
	return true

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var encoded_text := file.get_as_text()
	file.close()

	var json_text := Marshalls.base64_to_utf8(encoded_text)
	var parsed = JSON.parse_string(json_text)

	if not (parsed is Dictionary):
		return {}

	var wrapped_data: Dictionary = parsed
	if not wrapped_data.has("payload"):
		return {}

	var payload = wrapped_data["payload"]
	if payload is Dictionary:
		return payload

	return {}

func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
