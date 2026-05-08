extends Node2D

var operation_ui_scene: PackedScene = preload("res://Scenes/UIs/operation_ui.tscn")
var ui_scene: PackedScene = preload("res://Scenes/UIs/inventory_ui.tscn")
var shop_mgm_screen: PackedScene = preload("res://Scenes/UIs/shop_management_screen.tscn")
var shop_scene: PackedScene = preload("res://Scenes/Shop/shop.tscn")
var worker_mgm_panel: PackedScene = preload("res://Scenes/UIs/worker_panel.tscn")

var shop_instance: Shop = null
var operation_ui_instance: Control
var ui_instance: Control
var worker_mgm_panel_instance: WorkerPanel

var player_id = "1001"
var player_name = "Player"

@onready var research_manager: ResearchManager = $ResearchManager
@onready var store_display_item_manager: StoreDisplayItemManager = $StoreDisplayItemManager
@onready var inventory_manager: InventoryManager = $InventoryManager
@onready var worker_spawners: WorkerSpawner = $WorkerSpawners
@onready var worker_manager: WorkerManager = $WorkerManager
@onready var pause_manager: PauseManager = $PauseManager

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var pause_menu: Control = $CanvasLayer/PauseMenu


func _ready() -> void:
	Global.base_chance = 0.5
	Global.store_fame = 0.1
		

func _process(_delta: float) -> void:
	_handle_input()
		

func _handle_input() -> void:
	if Input.is_action_just_pressed("test"):
		research_manager.start_project("1013")
		
	if Input.is_action_just_pressed("save"):
		save_game()

	if Input.is_action_just_pressed("load"):
		load_game()


func game_start() -> void:
	if operation_ui_instance == null:
		operation_ui_instance = operation_ui_scene.instantiate()
		operation_ui_instance.setup(self)
		canvas_layer.add_child(operation_ui_instance)
	
	else:
		operation_ui_instance.visible = true
		
		
	if shop_instance == null:
		shop_instance = shop_scene.instantiate()
		add_child(shop_instance)
		shop_instance.setup(
			operation_ui_instance,
			worker_manager,
			store_display_item_manager,
			inventory_manager
			)
			
		var forbidden_item_ids: Array = shop_instance.current_stage_data.forbidden_item_ids
		var initial_unlocked_item_ids: Array = shop_instance.current_stage_data.initial_unlocked_item_ids
		
		research_manager.setup(inventory_manager)
		inventory_manager.setup_inventory(initial_unlocked_item_ids, forbidden_item_ids)
		
	else:
		shop_instance.visible = true
		shop_instance.resume_customer_spawner(operation_ui_instance)
		
	
	pause_menu.setup(self)
	pause_manager.setup(pause_menu)
	
	
	store_display_item_manager.setup(inventory_manager)
	

	worker_spawners.setup(shop_instance, worker_manager)
	
	# Check if the player is already spawned
	if not worker_manager.get_worker(player_id):
		worker_spawners.spawn_player(player_id, player_name)
		
		var cashier = shop_instance.get_unassigned_cashier(worker_manager)
		
		if cashier == null:
			push_error("[GameController] Cashier not found.")
			return
		
		worker_manager.assign_work(
			player_id,
			worker_manager.WorkRole.CASHIER,
			cashier
			)
	
	
	worker_manager.enter_gameplay_mode()
	
	_connecting_signals()
	
	AudioManager.play_bgm("shop")


func save_game() -> void:
	var save_data := {
		"store_lv": shop_instance.current_store_lv,
		"money": Global.money,
		"inventory": inventory_manager.get_save_data(),
		"displayed_items": store_display_item_manager.get_save_data(),
		"date": Global.date,
		"store_fame": Global.store_fame,
		"base_chance": Global.base_chance,
		"is_open": shop_instance.is_open,
		"cashier": shop_instance.get_cashier_save_data(),
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
		inventory_manager.load_from_data(inventory_data)
		
	# Load cashiers
	var cashier_data = save_data.get("cashier", {})
	if cashier_data is Dictionary:
		shop_instance.load_cashier_from_data(cashier_data)
		
	# Load dressers
	var dresser_data = save_data.get("dresser", {})
	if dresser_data is Dictionary:
		shop_instance.load_dresser_from_data(dresser_data)
		
		
	# Load Seleceted item
	var display_data = save_data.get("displayed_items", {})
	if display_data is Array:
		store_display_item_manager.load_from_data(display_data)
	
	# Place item spraites
	shop_instance.restore_display_items()
	
	
	print("[GameController] Game loaded")
	
	pause_manager.resume_game()


func spawn_worker() -> void:
	worker_spawners.spawn_hired_worker("2001", "Staff")
	

func change_display_item(slot: ItemSlot) -> void:
	store_display_item_manager.add_display_item(slot, shop_instance)


func cleanup_game_scene() -> void:
	
	# [REMAIN] shop instance but NOT visible
	if is_instance_valid(shop_instance):
		shop_instance.cleanup_customer_spawner()
		shop_instance.visible = false
		
		
	# [REMAIN] operation ui instance but NOT visible
	if is_instance_valid(operation_ui_instance):
		operation_ui_instance.hide()
		
		
	worker_manager.enter_management_mode()
		

func show_inventory_menu() -> void:
	if ui_instance:
		return
		
	ui_instance = ui_scene.instantiate()
	ui_instance.setup(self, store_display_item_manager, inventory_manager)
	
	canvas_layer.add_child(ui_instance)
	
	
func start_clean() -> void:
	print("Cleaning")


func show_worker_panel() -> void:
	worker_mgm_panel_instance = worker_mgm_panel.instantiate()
	canvas_layer.add_child(worker_mgm_panel_instance)
	
	worker_mgm_panel_instance.setup(worker_manager, shop_instance)
	worker_mgm_panel_instance.refresh_all_workers()


func open_shop() -> void:
	shop_instance.open_store()
	print("Open shop")


func close_shop() -> void:
	shop_instance.close_store()
	print("Close shop")


func proceed_next_day() -> void:
	
	# Caluculate daily reputation
	shop_instance.shop_stats.apply_daily_reputation_result()
	Global.date += 1
	
	# Clean up unnecesarry instances
	cleanup_game_scene()
		
	# Show management UI
	var shop_mgm_ui_instance = shop_mgm_screen.instantiate()
	canvas_layer.add_child(shop_mgm_ui_instance)
	shop_mgm_ui_instance.setup(self, shop_instance)
	
	
func _connecting_signals() -> void:
	if not research_manager.research_completed.is_connected(_on_research_completed):
		research_manager.research_completed.connect(_on_research_completed)
	
	
func _on_research_completed(project: ResearchProjectData) -> void:
	inventory_manager.unlock_item(project.project_id)
	print("Research_completed: %s" % project.project_id)
	
