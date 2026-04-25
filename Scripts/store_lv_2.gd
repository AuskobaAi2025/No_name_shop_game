extends Node2D
class_name StoreLv2

@onready var interiors: Node2D = $Interiors


#Cashier
@onready var item_icon_1: Sprite2D = $Interiors/Cashier/ItemIcon1
@onready var item_icon_2: Sprite2D = $Interiors/Cashier/ItemIcon2


var cashier_item_id_1: String
var cashier_item_id_2: String

# Dresser
var dresser_scene: PackedScene = preload("res://Scenes/Interiors/dresser.tscn")
var dresser_instance1: Dresser
var dresser_instance2: Dresser
var dresser_instances: Array[Dresser] = []

var dresser_1_pos: Vector2 = Vector2(-40, -64)
var dresser_2_pos: Vector2 = Vector2(40, -64)

# Position
var entrance_pos: Vector2 = Vector2(0, 50)
var front_counter1_pos: Vector2 = Vector2(0, 0)
var back_counter1_pos: Vector2 = Vector2(0, -40)

# Cashier
var initial_cashier_count: int = 1
var max_cashier_count: int = 1

# Dresser
var max_dresser_count: int = 2



func get_dresser_count() -> int:
	var count := 0

	if is_instance_valid(dresser_instance1):
		count += 1

	if is_instance_valid(dresser_instance2):
		count += 1

	return count


func add_dresser() -> bool:
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


func get_display_capacity() -> int:
	var total := 0

	for dresser in get_dressers():
		total += dresser.get_capacity()

	return total


func add_display_item(item_id: String) -> void:
	var item_data: ItemData = InventoryManager.get_item_data(item_id)
	if item_data == null:
		return
		
	if does_cashier_has_empty_slot():
		return add_item_to_cashier(item_data)

	for dresser in get_dressers():
		if dresser.has_empty_slot():
			return dresser.add_item(item_data)

	print("[Store] No empty dresser slot.")


func remove_display_item(item_id: String) -> void:
	if cashier_item_id_1 == item_id:
		cashier_item_id_1 = ""
		item_icon_1.texture = null
		item_icon_1.visible = false
		return 

	if cashier_item_id_2 == item_id:
		cashier_item_id_2 = ""
		item_icon_2.texture = null
		item_icon_2.visible = false
		return
		
	for dresser in get_dressers():
		if dresser.remove_item(item_id):
			return


func clear_display_items() -> void:
	for dresser in get_dressers():
		dresser.clear_items()
		
		
func does_cashier_has_empty_slot() -> bool:
	return cashier_item_id_1 == "" or cashier_item_id_2 == ""


func add_item_to_cashier(item_data: ItemData) -> bool:
	if item_data == null:
		return false

	if cashier_item_id_1 == "":
		cashier_item_id_1 = item_data.id
		item_icon_1.texture = item_data.icon
		item_icon_1.visible = true
		return true

	if cashier_item_id_2 == "":
		cashier_item_id_2 = item_data.id
		item_icon_2.texture = item_data.icon
		item_icon_2.visible = true
		return true

	return false
