extends Node
class_name StoreDisplayItemManager

const DISPLAY_LIMIT_PER_DRESSER: int = 2

var inventory_manager: InventoryManager

var dresser_count: int = 0
var cashier_count: int = 0
var selected_display_item_ids: Array[String] = []


func setup(manager: InventoryManager) -> void:
	inventory_manager = manager


func update_cashier_count() -> void:
	cashier_count += 1

func update_dresser_count() -> void:
	dresser_count += 1


func get_max_display_items() -> int:
	return (dresser_count * DISPLAY_LIMIT_PER_DRESSER) + (cashier_count * DISPLAY_LIMIT_PER_DRESSER)


func is_displayed(item_id: String) -> bool:
	return selected_display_item_ids.has(item_id)


func get_display_item_ids() -> Array[String]:
	return selected_display_item_ids.duplicate()


func get_display_item_count() -> int:
	return selected_display_item_ids.size()


func can_add_display_item(item_id: String) -> bool:
	if item_id == "":
		print("item_is is empty")
		return false

	if selected_display_item_ids.has(item_id):
		print("The item has been already selected")
		return false

	if selected_display_item_ids.size() >= get_max_display_items():
		print("Reached the max display item number")
		return false

	if inventory_manager.get_item_data(item_id) == null:
		print("The item doesn't exist")
		return false

	return true


func add_display_item(slot: ItemSlot, target_shop: Shop) -> void:
	var store = target_shop.current_store
	var item_id = slot.item_id
	
	if item_id == "":
		return

	if slot.is_selected:
		slot.set_selected(false)
		selected_display_item_ids.erase(item_id)
		store.remove_display_item(item_id)
		print("Display removed: ", item_id)
		return
		
	if not can_add_display_item(item_id):
		return
		
	slot.set_selected(true)
	selected_display_item_ids.append(item_id)
	store.add_display_item(item_id)
	
	
func clear_display_items() -> void:
	selected_display_item_ids.clear()
	
	
####SAVE AND LOAD####

func get_save_data() -> Array:
	return selected_display_item_ids.duplicate(true)
	
	
func load_from_data(data: Array) -> void:
	selected_display_item_ids.clear()
	
	for item_id in data:
		selected_display_item_ids.append(str(item_id))
