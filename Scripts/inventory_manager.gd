extends Node

signal inventory_changed

var item_list: Array[ItemData] = []

var item_database: Dictionary = {}
var inventory: Dictionary = {}


func _ready():
	_auto_load_items()

func _auto_load_items():
	var paths = [
		"res://Items/potion.tres",
		"res://Items/bread.tres",
		"res://Items/spear.tres",
		"res://Items/sheld.tres",
		"res://Items/pot.tres",
		]

	for path in paths:
		var item: ItemData = load(path)
		if item:
			item_database[item.id] = item


func get_save_data() -> Dictionary:
	return inventory.duplicate(true)

func load_from_data(data: Dictionary) -> void:
	inventory.clear()

	for item_id in data.keys():
		inventory[item_id] = int(data[item_id])


func reset():
	inventory.clear()
	emit_signal("inventory_changed")


func add_item(item_id: String, amount: int = 1, is_setup: bool = false) -> int:
	var item_data: ItemData = get_item_data(item_id)
	if item_data == null:
		push_error("Unknown item id: %s" % item_id)
		return 0

	var current: int = inventory.get(item_id, 0)
	var new_amount: int = clamp(current + amount, 0, item_data.max_stack)
	var added: int = new_amount - current
		
	if is_setup:

		inventory[item_id] = new_amount
		emit_signal("inventory_changed")
		return added
	
	Global.money -= item_data.price_restock * amount
	inventory[item_id] = new_amount
	emit_signal("inventory_changed")
	return added	
	

func remove_item(item_id: String, amount: int = 1) -> int:
	if not inventory.has(item_id):
		return 0

	var current: int = inventory.get(item_id, 0)
	var new_amount: int = max(current - amount, 0)
	var removed: int = current - new_amount

	if new_amount == 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = new_amount

	emit_signal("inventory_changed")
	return removed


func get_item_name(item_id: String) -> String:
	var item_data: ItemData = get_item_data(item_id)
	if item_data == null:
		return item_id  # fallback（ID返す or ""）
	return item_data.item_name


func get_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

func get_item_data(item_id: String) -> ItemData:
	return item_database.get(item_id, null)


func has_item(item_id: String, amount: int = 1) -> bool:
	return get_count(item_id) >= amount

func get_all_item_ids() -> Array:
	return inventory.keys()
