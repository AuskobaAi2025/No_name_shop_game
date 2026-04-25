extends Node2D
class_name Shop


var store_lv1: PackedScene = preload("res://Scenes/Stores/store_lv_1.tscn")
var store_lv2: PackedScene = preload("res://Scenes/Stores/store_lv_2.tscn")
var customer_spawner: PackedScene = preload("res://Scenes/Managers/customer_spawner.tscn")

var customer_spawner_instance: CustomerSpawner

var is_open: bool = false
var is_casher1_available: bool = true

var current_store: Node2D
var current_store_lv: int
var max_store_lv: int

var cashier_count: int
var max_cashier_count: int
var current_num_dressers: int = 0


@export var current_stage_data: StageData

var entrance_pos : Vector2
var front_counter1_pos : Vector2
var back_counter1_pos : Vector2


func setup(operation_ui: Control) -> void:
	#Store level
	max_store_lv = current_stage_data.max_store_lv
	set_store_lv(current_stage_data.initial_store_lv)
	
	customer_spawner_instance = customer_spawner.instantiate()
	add_child(customer_spawner_instance)
	customer_spawner_instance.setup(self, operation_ui)
	

####OPEN and CLOSE####


func open_store() -> void:
	if is_open:
		return
	is_open = true


func close_store() -> void:
	if not is_open:
		return
	is_open = false
	update_daily_average_satisfaction()
	apply_daily_reputation_result()


#####DRESSER######


func try_add_dresser() -> bool:
	if current_store == null:
		push_error("[Shop] Current store is null")
		return false
		
	return current_store.add_dresser()
	

func get_dressers_count() -> int:
	return current_store.dresser_instances.size()
	
	
####CASHIER####


func set_cashier_count(value: int) -> void:
	cashier_count = clamp(value, 0, max_cashier_count)


func get_cashier_count() -> int:
	return cashier_count
	
	
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
		
	for item_id in StoreDisplayItemManager.get_display_item_ids():
		print(item_id)
		current_store.add_display_item(item_id)

####STATS####

var daily_customer_count: int = 0
var daily_purchase_success_count: int = 0
var daily_satisfied_count: int = 0
var daily_normal_count: int = 0
var daily_dissatisfied_count: int = 0
var daily_total_satisfaction: float = 0.0
var daily_average_satisfaction: float = 0.0
var shop_reputation: float = 0.0


func reset_daily_stats() -> void:
	daily_customer_count = 0
	daily_purchase_success_count = 0
	daily_satisfied_count = 0
	daily_normal_count = 0
	daily_dissatisfied_count = 0
	daily_total_satisfaction = 0.0
	daily_average_satisfaction = 0.0


func register_customer_visit() -> void:
	daily_customer_count += 1


func report_customer_result(satisfaction_score: float, bought_successfully: bool) -> void:
	daily_total_satisfaction += satisfaction_score

	if bought_successfully:
		daily_purchase_success_count += 1

	if satisfaction_score >= 80.0:
		daily_satisfied_count += 1
	elif satisfaction_score >= 40.0:
		daily_normal_count += 1
	else:
		daily_dissatisfied_count += 1

	update_daily_average_satisfaction()


func update_daily_average_satisfaction() -> void:
	var total_finished_customers := daily_satisfied_count + daily_normal_count + daily_dissatisfied_count
	
	if total_finished_customers <= 0:
		daily_average_satisfaction = 0.0
		return

	daily_average_satisfaction = daily_total_satisfaction / float(total_finished_customers)


func apply_daily_reputation_result() -> void:
	shop_reputation += (daily_average_satisfaction - 50.0) * 0.05
	shop_reputation = clamp(shop_reputation, -100.0, 100.0)


func get_spawn_bonus_from_reputation() -> float:
	return shop_reputation * 0.002
	
	
####OTHERS####
	
	
func resume_customer_spawner(operation_ui: Control) -> void:
	customer_spawner_instance = customer_spawner.instantiate()
	add_child(customer_spawner_instance)
	customer_spawner_instance.setup(self, operation_ui)
	
	
func cleanup_customer_spawner() -> void:
	if is_instance_valid(customer_spawner_instance.spawn_timer):
		customer_spawner_instance.spawn_timer.stop()

	for customer in customer_spawner_instance.customers_in_line:
		if is_instance_valid(customer):
			customer.queue_free()

	customer_spawner_instance.customers_in_line.clear()


func get_max_line_size() -> int:
	return cashier_count * 3


func leveup_store() -> void:
	var target_lv = current_store_lv + 1
	set_store_lv(target_lv)


func set_store_lv(target_lv: int) -> void:
	if target_lv > max_store_lv:
		print("[shop.gd]: target_lv is greater than max_store_lv")
		return
	
	current_store_lv = target_lv
	
	var new_store: Node2D

	match target_lv:
		1:
			new_store = store_lv1.instantiate()
		2:
			new_store = store_lv2.instantiate()
		_:
			push_error("Error: invalid store level: %s" % target_lv)
			
	if current_store != null:
		current_store.queue_free()
		current_store = null
			
	add_child(new_store)
	current_store = new_store
	current_store_lv = target_lv
	
	
	entrance_pos = current_store.entrance_pos
	front_counter1_pos = current_store.front_counter1_pos
	back_counter1_pos = current_store.back_counter1_pos
	
	cashier_count = current_store.initial_cashier_count
	max_cashier_count = current_store.max_cashier_count
