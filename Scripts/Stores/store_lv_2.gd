extends Node2D
class_name StoreLv2

@onready var interiors: Node2D = $Interiors


# Dresser
var dresser_scene: PackedScene = preload("res://Scenes/Interiors/dresser.tscn")
var dresser_instance1: Dresser
var dresser_instance2: Dresser
var dresser_instances: Array[Dresser] = []
var max_dresser_count: int = 2	

var dresser_1_pos: Vector2 = Vector2(-40, -64)
var dresser_2_pos: Vector2 = Vector2(40, -64)

# Position
var entrance_pos: Vector2 = Vector2(0, 50)
var front_counter1_pos: Vector2 = Vector2(0, 0)
var back_counter1_pos: Vector2 = Vector2(0, -40)

# Cashier
var cashier_scene: PackedScene = preload("res://Scenes/Interiors/cashier.tscn")
var cashier_instance: Cashier

var cashier_pos: Vector2 = Vector2(0, -16)
var initial_cashier_count: int = 1
var max_cashier_count: int = 1



func setup() -> void:
	cashier_instance = cashier_scene.instantiate()
	interiors.add_child(cashier_instance)
	cashier_instance.setup(cashier_pos)


func get_dresser_count() -> int:
	var count := 0

	if is_instance_valid(dresser_instance1):
		count += 1

	if is_instance_valid(dresser_instance2):
		count += 1

	return count


func add_dresser() -> bool:
	# Check the max dresser num of the current store lv
	if get_dresser_count() >= max_dresser_count:
		print("[StoreLv2] Failed: Dresser count reached max.")
		return false

	if not is_instance_valid(dresser_instance1):
		dresser_instance1 = dresser_scene.instantiate()
		interiors.add_child(dresser_instance1)
		dresser_instance1.setup(dresser_1_pos)
		dresser_instances.append(dresser_instance1)
		StoreDisplayItemManager.update_dresser_count()
		print("[StoreLv2] Dresser 1 added")
		return true

	if not is_instance_valid(dresser_instance2):
		dresser_instance2 = dresser_scene.instantiate()
		interiors.add_child(dresser_instance2)
		dresser_instance2.setup(dresser_2_pos)
		dresser_instances.append(dresser_instance2)
		StoreDisplayItemManager.update_dresser_count()
		print("[StoreLv2] Dresser 2 added")
		return true

	push_error("[StoreLv2] Failed: No available dresser slot.")
	return false


func get_dressers() -> Array[Dresser]:
	var result: Array[Dresser] = []
	
	for dresser in dresser_instances:
		if is_instance_valid(dresser):
			result.append(dresser)
			
	return result


func get_displayable_furnitures() -> Array[DisplayableFurniture]:
	var result: Array[DisplayableFurniture] = []

	if is_instance_valid(cashier_instance):
		result.append(cashier_instance)

	for dresser in get_dressers():
		result.append(dresser)
		
	return result


func add_display_item(item_id: String) -> void:
	var item_data: ItemData = InventoryManager.get_item_data(item_id)
	if item_data == null:
		return

	for furniture in get_displayable_furnitures():
		if furniture.has_empty_slot():
			furniture.add_item(item_data)
			return

	print("[Store] No empty display slot.")


func remove_display_item(item_id: String) -> void:
	if cashier_instance.remove_item(item_id):
		return

	for dresser in get_dressers():
		if dresser.remove_item(item_id):
			return


func clear_display_items() -> void:
	cashier_instance.clear_items()

	for dresser in get_dressers():
		dresser.clear_items()
		
		
