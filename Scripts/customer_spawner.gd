extends Node
class_name CustomerSpawner

var customer_scene: PackedScene = preload("res://scenes/customer.tscn")

@onready var spawn_timer: Timer = $SpawnTimer

@export var spawn_interval: float = 3.0
@export var line_offset: Vector2 = Vector2(0, 24)

var shop: Shop = null
var item_candidates: Array = []
var customers_in_line: Array[Customer] = []


func setup(target_shop: Shop) -> void:
	shop = target_shop
	var dataset = shop.current_stage_data
	
	item_candidates = dataset.customer_wanted_item_ids
	
	spawn_timer.wait_time = dataset.base_spawn_interval
	spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	try_spawn_customer()


func try_spawn_customer() -> void:
	if shop == null:
		return

	var max_customers_in_line := shop.get_max_line_size()

	if not can_spawn_customer():
		return

	if not should_spawn_customer():
		return

	if customers_in_line.size() >= max_customers_in_line:
		return

	var customer: Customer = customer_scene.instantiate()
	var item_id: String = item_candidates.pick_random()
	var amount: int = 1

	customer.setup(item_id, amount, self, shop)
	customer.position = shop.entrance_pos

	add_child(customer)
	customers_in_line.append(customer)

	_update_line_positions()


func _update_line_positions() -> void:
	if shop == null:
		return

	for i in range(customers_in_line.size()):
		var customer := customers_in_line[i]
		if customer == null or not is_instance_valid(customer):
			continue
		if customer.is_returning:
			continue

		var wait_pos := shop.front_counter1_pos + line_offset * i
		customer.set_wait_position(wait_pos)


func is_front_customer(customer: Customer) -> bool:
	if customers_in_line.is_empty():
		return false
	return customers_in_line[0] == customer


func on_customer_left(customer: Customer) -> void:
	var index := customers_in_line.find(customer)
	if index != -1:
		customers_in_line.remove_at(index)
		_update_line_positions()


func can_spawn_customer() -> bool:
	if shop == null:
		return false

	if not shop.is_open:
		return false

	return true


func should_spawn_customer() -> bool:
	if shop == null:
		return false
		
	var chance := Global.base_chance + Global.store_fame + shop.get_spawn_bonus_from_reputation()
	return randf() < clamp(chance, 0.0, 0.8)
