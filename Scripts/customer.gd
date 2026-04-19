extends Node2D
class_name Customer

@onready var timer: Timer = $Timer

var is_returning: bool = false
var has_bought: bool = false
var has_reported_result: bool = false
var speed: float = 30.0

var desired_item_id: String = ""
var desired_amount: int = 1

var target_position: Vector2
var spawner: CustomerSpawner = null
var shop: Shop = null

var satisfaction_score: float = 100.0
var satisfaction_state: String = "normal"
var wait_time: float = 0.0
var max_tolerable_wait_time: float
var could_buy_desired_item: bool = false
var left_reason: String = ""


func setup(item_id: String, amount: int, owner_spawner: CustomerSpawner, target_shop: Shop) -> void:
	desired_item_id = item_id
	desired_amount = amount
	spawner = owner_spawner
	shop = target_shop
	
	max_tolerable_wait_time = shop.current_stage_data.customer_wait_tolerance


func _ready() -> void:
	if shop != null:
		shop.register_customer_visit()
		target_position = shop.entrance_pos
		

func _process(delta: float) -> void:
	if not is_returning and not has_bought:
		wait_time += delta

	position = position.move_toward(target_position, speed * delta)

	if position.distance_to(target_position) < 1.0:
		_on_reached_target()

	_update_wait_satisfaction(delta)


func _on_reached_target() -> void:
	if is_returning:
		if shop != null and position.distance_to(shop.entrance_pos) < 1.0:
			if spawner != null:
				spawner.on_customer_left(self)
			queue_free()
		return

	if spawner != null and spawner.is_front_customer(self):
		if timer.is_stopped():
			timer.start()


func _update_wait_satisfaction(_delta: float) -> void:
	if is_returning or has_bought:
		return

	if wait_time > max_tolerable_wait_time:
		satisfaction_score -= 0.2
		satisfaction_score = max(satisfaction_score, 0.0)


func buy_items() -> void:
	if has_bought:
		print("[BUY] skipped: already bought")
		return

	var stock_amount: int = InventoryManager.get_count(desired_item_id)
	var item_data: ItemData = InventoryManager.get_item_data(desired_item_id)

	if item_data == null:
		has_bought = true
		could_buy_desired_item = false
		left_reason = "item_data_not_found"
		satisfaction_score -= 60.0
		finalize_customer_result()
		start_returning()

		print("[BUY] FAIL: item_data null | id=", desired_item_id)
		return
		
		
	if not desired_item_id in shop.selected_display_item_ids:
		has_bought = true
		could_buy_desired_item = false
		left_reason = "item_data_not_found"
		satisfaction_score -= 60.0
		finalize_customer_result()
		start_returning()
		print("[BUY] FAIL: item_data not display | id=", desired_item_id)
		return
		

	if stock_amount < desired_amount:
		has_bought = true
		could_buy_desired_item = false
		left_reason = "out_of_stock"
		satisfaction_score -= 50.0
		finalize_customer_result()
		start_returning()

		print("[BUY] FAIL: stock insufficient | id=", desired_item_id, " stock=", stock_amount, " need=", desired_amount)
		return
		
	InventoryManager.remove_item(desired_item_id, desired_amount)
	Global.money += item_data.price_sell * desired_amount

	has_bought = true
	could_buy_desired_item = true
	left_reason = "bought"

	satisfaction_score += 10.0
	if wait_time > 5.0:
		satisfaction_score -= 20.0
	elif wait_time > 2.5:
		satisfaction_score -= 10.0

	finalize_customer_result()
	start_returning()
	
	print("[BUY] SUCCESS: ", item_data.item_name, " x", desired_amount, " wait=", wait_time)


func finalize_customer_result() -> void:
	satisfaction_score = clamp(satisfaction_score, 0.0, 100.0)

	if satisfaction_score >= 80.0:
		satisfaction_state = "satisfied"
	elif satisfaction_score >= 40.0:
		satisfaction_state = "normal"
	else:
		satisfaction_state = "dissatisfied"

	if has_reported_result:
		return

	has_reported_result = true

	if shop != null:
		shop.report_customer_result(satisfaction_score, could_buy_desired_item)


func start_returning() -> void:
	is_returning = true
	if shop != null:
		target_position = shop.entrance_pos


func set_wait_position(pos: Vector2) -> void:
	if not is_returning:
		target_position = pos


func _on_timer_timeout() -> void:
	if has_bought:
		return

	if shop == null:
		return

	if not has_bought and shop.is_casher1_available:
		buy_items()
