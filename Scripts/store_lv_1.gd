extends Node2D
class_name StoreLv1

@onready var interiors: Node2D = $Interiors

#Cashier
@onready var item_icon_1: Sprite2D = $Interiors/Cashier/ItemIcon1
@onready var item_icon_2: Sprite2D = $Interiors/Cashier/ItemIcon2


var cashier_item_id_1: String
var cashier_item_id_2: String

#Dresser
var dresser_scene: PackedScene = preload("res://Scenes/Interiors/dresser.tscn")
var dresser_instances: Array[Dresser] = []


# Position for people
var entrance_pos: Vector2 = Vector2(0, 50)
var front_counter1_pos: Vector2 = Vector2(0, 0)
var back_counter1_pos: Vector2 = Vector2(0, -40)

# Cashier
var initial_cashier_count: int = 1
var max_cashier_count: int = 1

# Dresser
var max_dresser_count: int = 0


func add_dresser() -> bool:
	print("[StoreLv1] Failed: No available dresser slot.")
	return false


func get_dressers() -> Array[Dresser]:
	var result: Array[Dresser] = []
	print("[StoreLv1] Failed: No available dresser slot.")
	return result


func get_display_capacity() -> int:
	print("[StoreLv1] Failed: No available dresser slot.")
	return 0


func add_display_item(item_id: String) -> void:
	var item_data: ItemData = InventoryManager.get_item_data(item_id)
	if item_data == null:
		return
		
	if does_cashier_has_empty_slot():
		add_item_to_cashier(item_data)
		return

	print("[Store] No empty slot.")


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

		
	print("[StoreLv1] Failed: No available dresser slot.")


func clear_display_items() -> void:
	for dresser in get_dressers():
		dresser.clear_items()
	print("[StoreLv1] Failed: No available dresser slot.")


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
