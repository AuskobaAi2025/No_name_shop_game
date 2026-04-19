extends Node2D

@onready var customer_spawner: CustomerSpawner = $Shop/CustomerSpawner
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var shop: Shop = $Shop

var player_scene: PackedScene = preload("res://Scenes/player.tscn")
var ui_scene: PackedScene = preload("res://Scenes/inventory_ui.tscn")
var player_instance: Node2D
var ui_instance: Control


func _ready() -> void:
	Global.base_chance = 0.5
	Global.store_fame = 0.1
	
	game_start()
		

func _process(delta: float) -> void:
	_hundle_input(delta, player_instance)

	if ui_instance == null:
		if not player_instance.is_acting:
			shop.is_casher1_available = true


func _hundle_input(delta: float, player_instance) -> void:
	if Input.is_action_just_pressed("test"):
		if ui_instance != null:
			shop.is_casher1_available = true
			ui_instance.queue_free()
			ui_instance = null

	if Input.is_action_just_pressed("save"):
		save_game()

	if Input.is_action_just_pressed("load"):
		load_game()


func game_start() -> void:
	shop.setup()
	customer_spawner.setup(shop)

	player_instance = player_scene.instantiate()
	player_instance.setup(shop)
	add_child(player_instance)


func save_game() -> void:
	var save_data := {
		"store_lv": shop.current_store_lv,
		"money": Global.money,
		"inventory": InventoryManager.get_save_data(),
		"date": Global.date,
		"store_fame": Global.store_fame,
		"base_chance": Global.base_chance,
		"is_open": shop.is_open
	}

	var ok := SaveLoadManager.save_game(save_data)

	if ok:
		print("[GameController] Game saved")
	else:
		print("[GameController] Save failed")


func load_game() -> void:
	var save_data := SaveLoadManager.load_game()
	if save_data.is_empty():
		print("[GameController] No save data")
		game_start()
		return

	game_start()

	var store_lv: int = int(save_data.get("store_lv", 1))
	Global.money = int(save_data.get("money", 0))
	Global.date = int(save_data.get("date", 1))
	Global.store_fame = float(save_data.get("store_fame", 0.1))
	Global.base_chance = float(save_data.get("base_chance", 0.5))
	shop.is_open = bool(save_data.get("is_open", false))

	var inventory_data = save_data.get("inventory", {})
	if inventory_data is Dictionary:
		InventoryManager.load_from_data(inventory_data)

	shop.set_store_lv(store_lv)
	update_ui_load()

	print("[GameController] Game loaded")


func update_ui_load() -> void:
	pass


func _on_restock_button_pressed() -> void:
	if ui_instance:
		return
		
	ui_instance = ui_scene.instantiate()
	ui_instance.setup(shop)
	
	canvas_layer.add_child(ui_instance)
	
	shop.is_casher1_available = false


func _on_clean_room_button_pressed() -> void:
	player_instance.start_action("clean")
	shop.is_casher1_available = false


func _on_info_button_pressed() -> void:
	print("Show info")


func _on_open_shop_button_pressed() -> void:
	shop.is_open = true
	print("Open shop")


func _on_close_shop_button_pressed() -> void:
	shop.is_open = false
	print("Close shop")


func _on_next_day_button_pressed() -> void:
	print("Next day...")
	shop.apply_daily_reputation_result()
	Global.date += 1
