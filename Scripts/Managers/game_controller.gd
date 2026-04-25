extends Node2D

@onready var pause_manager: PauseManager = $PauseManager
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var operation_ui: Control = $CanvasLayer/OperationUI
@onready var pause_menu: Control = $CanvasLayer/PauseMenu

var player_scene: PackedScene = preload("res://Scenes/player.tscn")
var ui_scene: PackedScene = preload("res://Scenes/UIs/inventory_ui.tscn")
var shop_management_screen: PackedScene = preload("res://Scenes/UIs/shop_management_screen.tscn")
var shop: PackedScene = preload("res://Scenes/shop.tscn")

var shop_instance: Shop = null
var player_instance: Node2D
var ui_instance: Control


func _ready() -> void:
	Global.base_chance = 0.5
	Global.store_fame = 0.1
	
	game_start()
		

func _process(delta: float) -> void:
	_hundle_input(delta, player_instance)

	if ui_instance == null and player_instance != null:
		if not player_instance.is_acting:
			shop_instance.is_casher1_available = true
		


func _hundle_input(delta: float, player_instance) -> void:
	if Input.is_action_just_pressed("test"):
		pass
		
	if Input.is_action_just_pressed("save"):
		save_game()

	if Input.is_action_just_pressed("load"):
		load_game()


func game_start() -> void:
	if is_instance_valid(operation_ui) and not operation_ui.visible:
		operation_ui.show()
		
	if shop_instance == null:
		shop_instance = shop.instantiate()
		add_child(shop_instance)
		shop_instance.setup(operation_ui)
		
	else:
		shop_instance.visible = true
		shop_instance.resume_customer_spawner(operation_ui)
		

	pause_menu.setup(self)
	pause_manager.setup(pause_menu)

	player_instance = player_scene.instantiate()
	player_instance.setup(shop_instance)
	add_child(player_instance)
	
	AudioManager.play_bgm("shop")


func save_game() -> void:
	var save_data := {
		"store_lv": shop_instance.current_store_lv,
		"money": Global.money,
		"inventory": InventoryManager.get_save_data(),
		"displayed_items": StoreDisplayItemManager.get_save_data(),
		"date": Global.date,
		"store_fame": Global.store_fame,
		"base_chance": Global.base_chance,
		"is_open": shop_instance.is_open,
		"dresser": shop_instance.get_dresser_save_data()
	}
	
	
	var ok := SaveLoadManager.save_game(save_data)

	if ok:
		print("[GameController] Game saved")
	else:
		print("[GameController] Save failed")
		
	pause_manager.resume_game()


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
	shop_instance.is_open = bool(save_data.get("is_open", false))
	
	
	# Set StoreLv
	shop_instance.set_store_lv(store_lv)
	
	# Load inventory data
	var inventory_data = save_data.get("inventory", {})
	if inventory_data is Dictionary:
		InventoryManager.load_from_data(inventory_data)
		
		
	# Load dressers
	var dresser_data = save_data.get("dresser", {})
	if dresser_data is Dictionary:
		shop_instance.load_dresser_from_data(dresser_data)
		
		
	# Load Seleceted item
	var display_data = save_data.get("displayed_items", {})
	if display_data is Array:
		print("called")
		StoreDisplayItemManager.load_from_data(display_data)
	
	# Place item spraites
	shop_instance.restore_display_items()
	
	
	print("[GameController] Game loaded")
	
	pause_manager.resume_game()


func change_display_item(slot: ItemSlot) -> void:
	StoreDisplayItemManager.add_display_item(slot, shop_instance)


func cleanup_game_scene() -> void:
	if is_instance_valid(shop_instance):
		shop_instance.cleanup_customer_spawner()
		shop_instance.visible = false
		
		
	if is_instance_valid(player_instance):
		player_instance.queue_free()
		player_instance = null
		
	if is_instance_valid(operation_ui):
		operation_ui.hide()
		

func _on_restock_button_pressed() -> void:
	var stage_hidden_item_ids: Array[String] = shop_instance.current_stage_data.hidden_item_ids
	
	if ui_instance:
		return
		
	ui_instance = ui_scene.instantiate()
	ui_instance.setup(self, stage_hidden_item_ids)
	
	canvas_layer.add_child(ui_instance)
	
	shop_instance.is_casher1_available = false


func _on_clean_room_button_pressed() -> void:
	player_instance.start_action("clean")
	shop_instance.is_casher1_available = false


func _on_info_button_pressed() -> void:
	print("Show info")


func _on_open_shop_button_pressed() -> void:
	shop_instance.is_open = true
	print("Open shop")


func _on_close_shop_button_pressed() -> void:
	shop_instance.is_open = false
	print("Close shop")


func _on_next_day_button_pressed() -> void:
	shop_instance.apply_daily_reputation_result()
	Global.date += 1
	
	# Clean up unnecesarry scenes
	cleanup_game_scene()
		
	# Show management UI
	var shop_mgm_instance = shop_management_screen.instantiate()
	canvas_layer.add_child(shop_mgm_instance)
	shop_mgm_instance.setup(self, shop_instance)
	
