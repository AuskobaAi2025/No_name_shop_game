extends Node
class_name InventoryManager

signal inventory_changed

# For absolute databse for item
var item_database: Dictionary = {}

# Used for showing in inventory ui
var inventory: Dictionary = {}

# Used for saving and loading
var selected_item_ids: Array[String] = []

func _ready():
	_auto_load_items()


func _auto_load_items():
	var paths = [
		"res://Resources/Items/potion.tres",
		"res://Resources/Items/bread.tres",
		"res://Resources/Items/spear.tres",
		"res://Resources/Items/sheld.tres",
		"res://Resources/Items/pot.tres",
		"res://Resources/Items/high_potion.tres",
		"res://Resources/Items/magic_potion.tres"
		]

	for path in paths:
		var item: ItemData = load(path)
		if item:
			item_database[item.id] = item


func setup_inventory(
	initial_unlocked_item_ids: Array[String],
	forbidden_item_ids: Array[String] = []
) -> void:
	inventory.clear()

	for item_id in initial_unlocked_item_ids:
		if forbidden_item_ids.has(item_id):
			continue

		if not item_database.has(item_id):
			push_error("[InventoryManager] Unknown initial item id: %s" % item_id)
			continue

		inventory[item_id] = 0

	emit_signal("inventory_changed")
	
	
func get_save_data() -> Dictionary:
	return inventory.duplicate(true)
	
	
func load_from_data(data: Dictionary) -> void:
	inventory.clear()
	
	for item_id in data.keys():
		inventory[item_id] = int(data[item_id])

	emit_signal("inventory_changed")


func reset():
	inventory.clear()
	emit_signal("inventory_changed")


func add_item(item_id: String, amount: int = 1, should_pay_cost: bool = true) -> int:
	var item_data: ItemData = get_item_data(item_id)
	if item_data == null:
		push_error("Unknown item id: %s" % item_id)
		return 0

	var current_amount: int = inventory.get(item_id, 0)
	var new_amount: int = clamp(current_amount + amount, 0, item_data.max_stack)
	var added: int = new_amount - current_amount

	if should_pay_cost:
		Global.money -= item_data.price_restock * added

	inventory[item_id] = new_amount
	emit_signal("inventory_changed")
	return added


func remove_item(item_id: String, amount: int = 1) -> int:
	if not inventory.has(item_id):
		return 0

	var current_amount: int = inventory.get(item_id, 0)
	var new_amount: int = max(current_amount - amount, 0)
	var removed: int = current_amount - new_amount

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
	
	
func unlock_item(item_id: String) -> void:
	if item_id == "":
		push_error("[InventoryManager] item_id is empty.")
		return

	if not item_database.has(item_id):
		push_error("[InventoryManager] Unknown item id: %s" % item_id)
		return

	if inventory.has(item_id):
		print("[InventoryManager] Item already unlocked: %s" % item_id)
		return

	inventory[item_id] = 0
	print("[InventoryManager] Item unlocked: %s" % item_id)

	emit_signal("inventory_changed")
	
	
func is_item_available(item_id: String) -> bool:
	return inventory.has(item_id)
	
	
