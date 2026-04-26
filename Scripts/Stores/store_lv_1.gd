extends Node2D
class_name StoreLv1

@onready var interiors: Node2D = $Interiors

#Dresser
var dresser_scene: PackedScene = preload("res://Scenes/Interiors/dresser.tscn")
var dresser_instance1: Dresser
var dresser_instance2: Dresser
var dresser_instances: Array[Dresser] = []
var max_dresser_count: int = 0	


# Position for people
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
	print("[StoreLv1] Failed: No available dresser slot.")
	return 0


func add_dresser() -> bool:
	print("[StoreLv1] Failed: No available dresser slot.")
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
