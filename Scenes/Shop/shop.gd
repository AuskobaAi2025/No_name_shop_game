extends Node2D
class_name Shop

#### PackedScenes ####
var store_lv1: PackedScene = preload("res://Scenes/Shop/Stores/store_lv_1.tscn")
var store_lv2: PackedScene = preload("res://Scenes/Shop/Stores/store_lv_2.tscn")
var store_lv3: PackedScene = preload("res://Scenes/Shop/Stores/store_lv_3.tscn")
var customer_spawner_scene: PackedScene = preload("res://Scenes/Core/Systems/Spawners/customer_spawner.tscn")

#### Instances ####
var current_store: Node2D
var customer_spawner_instance: CustomerSpawner

#### External Dependencies ####
var worker_manager: WorkerManager
var item_display_manager: StoreDisplayItemManager
var inventory_manager: InventoryManager

#### State ####
var is_open: bool = false

#### Store Level ####
var current_store_lv: int
var max_store_lv: int

#### Cashier ####
var max_cashier_count: int

#### Furniture ####
var current_num_dressers: int = 0

#### Stage ####
@export var current_stage_data: StageData

#### Positions ####
var entrance_pos: Vector2

@onready var shop_stats: ShopStats = $ShopStats


func setup(
	operation_ui: Control,
	manager: WorkerManager,
	manager2: StoreDisplayItemManager,
	manager3: InventoryManager
	) -> void:
	
	worker_manager = manager
	item_display_manager = manager2
	inventory_manager = manager3
	
	#Store level
	max_store_lv = current_stage_data.max_store_lv
	set_store_lv(current_stage_data.initial_store_lv)
	
	customer_spawner_instance = customer_spawner_scene.instantiate()
	add_child(customer_spawner_instance)
	customer_spawner_instance.setup(self, operation_ui, item_display_manager, inventory_manager)
	

####OPEN and CLOSE####


func open_store() -> void:
	if is_open:
		return
	is_open = true


func close_store() -> void:
	if not is_open:
		return
	is_open = false
	shop_stats.update_daily_average_satisfaction()
	shop_stats.apply_daily_reputation_result()


#####DRESSER######


func try_add_dresser() -> bool:
	if current_store == null:
		push_error("[Shop] Current store is null")
		return false
		
	return current_store.add_dresser()
	

func get_dressers_count() -> int:
	return current_store.dresser_instances.size()
	
	
####Worker####

func get_work_position(target: Node2D) -> Vector2:
	if target == null:
		push_error("[Shop] get_work_position: target is null")

	if not target.has_method("get_worker_stand_pos"):
		push_error("[Shop] target has no get_worker_stand_pos()")

	return target.get_worker_stand_pos()
	
	
####CASHIER####
var cashiers: Array[Node] = []
var occupied_cashiers: Dictionary = {}

func get_cashier_save_data() -> Dictionary:
	if current_store == null:
		return {}

	if not "cashier_instances" in current_store:
		return {}

	var data := {
		"count": current_store.cashier_instances.size()
	}

	return data


func load_cashier_from_data(data: Dictionary) -> void:
	if current_store == null:
		return

	var count: int = int(data.get("count", 0))

	for i in count:
		current_store.add_cashier()


func try_add_cashier() -> bool:
	if current_store == null:
		push_error("[Shop] Current store is null")
		return false
		
	return current_store.add_cashier()


func get_cashier_slots() -> Array[Dictionary]:
	return current_store.get_cashier_slots()


func _get_available_checkout_slot() -> Dictionary:
	for slot in get_cashier_slots():
		var cashier = slot["cashier"]

		if occupied_cashiers.has(cashier):
			continue

		if not worker_manager.has_assigned_worker(
			WorkerManager.WorkRole.CASHIER,
			cashier
		):
			continue

		return slot

	return {}
	
	
func reserve_cashier(customer) -> Dictionary:
	var slot := _get_available_checkout_slot()

	if slot.is_empty():
		return {}

	var cashier = slot["cashier"]
	occupied_cashiers[cashier] = customer

	return slot
	
	
func release_cashier(cashier) -> void:
	occupied_cashiers.erase(cashier)


func get_cashier_count() -> int:
	return current_store.cashier_instances.size()
	
	
func _has_working_cashier() -> bool:
	if worker_manager == null:
		return false

	for cashier in get_cashiers():
		if worker_manager.has_assigned_worker(
			WorkerManager.WorkRole.CASHIER,
			cashier
		):
			return true

	return false


func can_checkout() -> bool:
	return _has_working_cashier()
	
	
func get_cashiers() -> Array[Node]:
	if current_store == null:
		return []

	return current_store.get_cashiers()
	
	
func get_unassigned_cashier(worker_manager: WorkerManager) -> Node:
	for cashier in get_cashiers():
		if not worker_manager.has_assigned_worker(
			WorkerManager.WorkRole.CASHIER,
			cashier
		):
			return cashier

	return null
	
	
func get_line_position(index: int) -> Vector2:
	return current_store.get_line_position(index)
	
	
func get_max_line_size() -> int:
	var actual_cashier_count := get_cashiers().size()

	if actual_cashier_count <= 0:
		return 0

	return actual_cashier_count * 3
	
	
####SAVE AND LOAD####

func get_dresser_save_data() -> Dictionary:
	if current_store == null:
		return {}

	if not "dresser_instances" in current_store:
		return {}

	var data := {
		"count": current_store.dresser_instances.size()
	}

	return data


func load_dresser_from_data(data: Dictionary) -> void:
	if current_store == null:
		return

	var count: int = int(data.get("count", 0))

	for i in count:
		current_store.add_dresser()


func restore_display_items() -> void:
	if current_store == null:
		return
		
	for item_id in item_display_manager.get_display_item_ids():
		current_store.add_display_item(item_id)
	
	
####OTHERS####
	
	
func resume_customer_spawner(operation_ui: Control) -> void:
	customer_spawner_instance = customer_spawner_scene.instantiate()
	add_child(customer_spawner_instance)
	customer_spawner_instance.setup(self, operation_ui, item_display_manager, inventory_manager)
	
	
func cleanup_customer_spawner() -> void:
	if customer_spawner_instance == null:
		return
		
	if is_instance_valid(customer_spawner_instance.spawn_timer):
		customer_spawner_instance.spawn_timer.stop()

	for customer in customer_spawner_instance.customers_in_line:
		if is_instance_valid(customer):
			customer.queue_free()

	customer_spawner_instance.customers_in_line.clear()


func leveup_store() -> void:
	var target_lv = current_store_lv + 1
	set_store_lv(target_lv)


func set_store_lv(target_lv: int) -> void:
	if target_lv > max_store_lv:
		print("[shop.gd]: target_lv is greater than max_store_lv")
		return
	
	# Clean up previous store and selected_display_item_ids
	if current_store != null:
		current_store.queue_free()
		current_store = null
	
	item_display_manager.clear_display_items()
	
	# Start to set up a new store lv
	current_store_lv = target_lv
	
	var new_store: Node2D
	
	match target_lv:
		1:
			new_store = store_lv1.instantiate()
		2:
			new_store = store_lv2.instantiate()
		3:
			new_store = store_lv3.instantiate()
		_:
			push_error("Error: invalid store level: %s" % target_lv)
			
	
	add_child(new_store)
	current_store = new_store
	current_store_lv = target_lv
	current_store.setup(item_display_manager, inventory_manager)
	
	
	entrance_pos = current_store.entrance_pos
	
	max_cashier_count = current_store.max_cashier_count
	
	
	occupied_cashiers.clear()
	
