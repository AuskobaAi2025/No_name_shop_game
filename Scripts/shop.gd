extends Node2D
class_name Shop

@onready var customer_spawner: CustomerSpawner = $CustomerSpawner

@onready var floor_layer_lv1: TileMapLayer = $StoreLv1/FloorLayer
@onready var floor_layer_lv2: TileMapLayer = $StoreLv2/FloorLayer
@onready var dresser_1: Sprite2D = $Interiors/Dresser1
@onready var dresser_2: Sprite2D = $Interiors/Dresser2


var is_open: bool = false
var is_casher1_available: bool = true
var current_store_lv: int = 1
var cashier_count: int = 1
var max_cashier_count: int = 3
var base_display_item_num: int = 2

# the position for customers in store lv1
var lv1_entrance_pos : Vector2 = Vector2(0, 50)
var lv1_front_counter1_pos : Vector2 = Vector2(0, 0)

# the position for the player
var lv1_back_counter1_pos : Vector2 = Vector2(0, -40)

var daily_customer_count: int = 0
var daily_purchase_success_count: int = 0
var daily_satisfied_count: int = 0
var daily_normal_count: int = 0
var daily_dissatisfied_count: int = 0
var daily_total_satisfaction: float = 0.0
var daily_average_satisfaction: float = 0.0

var shop_reputation: float = 0.0

var selected_display_item_ids: Array[String]
var max_display_item_count: int = 2
#var max_display_item_count: int:
#	get:
#		return shop.get_display_item_num()

func _ready() -> void:
	customer_spawner.setup(self)
	set_store_lv(current_store_lv)


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


func set_cashier_count(value: int) -> void:
	cashier_count = clamp(value, 0, max_cashier_count)


func get_cashier_count() -> int:
	return cashier_count


func get_max_line_size() -> int:
	return cashier_count * 3


func get_display_item_num() -> int:
	var adding_display_num := 0

	if dresser_1.visible:
		adding_display_num += 2

	if dresser_2.visible:
		adding_display_num += 2

	return base_display_item_num + adding_display_num


func set_store_lv(target_lv: int) -> void:
	current_store_lv = target_lv

	match target_lv:
		1:
			floor_layer_lv1.visible = true
			floor_layer_lv2.visible = false
		2:
			floor_layer_lv1.visible = false
			floor_layer_lv2.visible = true
		_:
			push_error("Error: invalid store level: %s" % target_lv)


func get_spawn_bonus_from_reputation() -> float:
	return shop_reputation * 0.002
