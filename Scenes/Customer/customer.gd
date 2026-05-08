extends Node2D
class_name Customer

@onready var timer: Timer = $Timer

var customer_comments: Array[String] = [
	"いい買い物ができた！",
	"また来るよ。",
	"この店、なかなかいいね。",
	"品揃えが良かった。",
	"ちょっと高いけど満足。",
	"探してた物があった！",
	"接客が良かった。",
	"また利用したい。"
]


var is_returning: bool = false
var has_bought: bool = false
var has_reported_result: bool = false
var speed: float = 30.0

var desired_item_id: String = ""
var desired_amount: int = 1

var target_position: Vector2
var spawner: CustomerSpawner
var shop: Shop
var operation_ui: Control

var satisfaction_score: float = 100.0
var satisfaction_state: String = "normal"
var wait_time: float = 0.0
var max_tolerable_wait_time: float
var could_buy_desired_item: bool = false
var left_reason: String = ""

# Cashier
var assigned_cashier: Node = null
var assigned_cashier_slot: Dictionary = {}
var is_moving_to_cashier: bool = false
var is_checking_out: bool = false

var item_display_manager: StoreDisplayItemManager
var inventory_manager: InventoryManager

func setup(
	item_id: String,
	amount: int,
	owner_spawner: CustomerSpawner,
	manager: StoreDisplayItemManager,
	manager2: InventoryManager,
	target_shop: Shop,
	target_ui: Control
	) -> void:
		
	desired_item_id = item_id
	desired_amount = amount
	spawner = owner_spawner
	shop = target_shop
	operation_ui = target_ui
	item_display_manager = manager
	inventory_manager = manager2
	
	max_tolerable_wait_time = shop.current_stage_data.customer_wait_tolerance


func _ready() -> void:
	if shop != null:
		shop.shop_stats.register_customer_visit()
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
			AudioManager.play_se("exit")
			queue_free()
		return

	if is_moving_to_cashier:
		is_moving_to_cashier = false
		is_checking_out = true

		if timer.is_stopped():
			timer.start()

		return

	if spawner != null and spawner.is_front_customer(self):
		try_go_to_cashier()


func try_go_to_cashier() -> void:
	if shop == null:
		return

	if assigned_cashier != null:
		return

	var slot := shop.reserve_cashier(self)

	if slot.is_empty():
		print("[Customer] waiting in line: no available cashier")
		return

	assigned_cashier_slot = slot
	assigned_cashier = slot.get("cashier", null)

	var customer_pos: Vector2 = assigned_cashier.get_customer_stand_pos()

	is_moving_to_cashier = true
	target_position = customer_pos

	if spawner != null:
		spawner.remove_from_line(self)
		
		
func _update_wait_satisfaction(_delta: float) -> void:
	if is_returning or has_bought:
		return

	if wait_time > max_tolerable_wait_time:
		satisfaction_score -= 0.2
		satisfaction_score = max(satisfaction_score, 0.0)


func buy_items() -> void:
	if has_bought:
		#print("[BUY] skipped: already bought")
		return
		

	var stock_amount: int = inventory_manager.get_count(desired_item_id)
	var item_data: ItemData = inventory_manager.get_item_data(desired_item_id)

	if item_data == null:
		has_bought = true
		could_buy_desired_item = false
		left_reason = "item_data_not_found"
		satisfaction_score -= 60.0
		finalize_customer_result()
		start_returning()

		#print("[BUY] FAIL: item_data null | id=", desired_item_id)
		return
		
		
	if not desired_item_id in item_display_manager.selected_display_item_ids:
		has_bought = true
		could_buy_desired_item = false
		left_reason = "item_data_not_found"
		satisfaction_score -= 60.0
		finalize_customer_result()
		start_returning()
		#print("[BUY] FAIL: item_data not display | id=", desired_item_id)
		return
		

	if stock_amount < desired_amount:
		has_bought = true
		could_buy_desired_item = false
		left_reason = "out_of_stock"
		satisfaction_score -= 50.0
		finalize_customer_result()
		start_returning()

		#print("[BUY] FAIL: stock insufficient | id=", desired_item_id, " stock=", stock_amount, " need=", desired_amount)
		return
		
	inventory_manager.remove_item(desired_item_id, desired_amount)
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
	
	AudioManager.play_se("coin")
	print("[BUY] SUCCESS: ", item_data.item_name, " x", desired_amount, " wait=", wait_time)
	
	left_comment()
	
	if spawner != null:
		spawner.try_send_front_customer_to_cashier()
	
	
func left_comment() -> void:
	var comment = customer_comments.pick_random()
	operation_ui.add_comment(comment)
	

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
		shop.shop_stats.report_customer_result(satisfaction_score, could_buy_desired_item)


func start_returning() -> void:
	is_returning = true
	is_checking_out = false
	is_moving_to_cashier = false

	if shop != null:
		shop.release_cashier(assigned_cashier)
		target_position = shop.entrance_pos


func set_wait_position(pos: Vector2) -> void:
	if is_returning:
		return

	if is_moving_to_cashier:
		return

	if is_checking_out:
		return

	target_position = pos


func _on_timer_timeout() -> void:
	if has_bought:
		return

	if shop == null:
		return

	if not is_checking_out:
		return

	buy_items()
