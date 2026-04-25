extends Node2D
class_name Dresser

@onready var item_icon_1: Sprite2D = $ItemIcon1
@onready var item_icon_2: Sprite2D = $ItemIcon2

var item_icon_1_pos: Vector2 = Vector2(10, -12)
var item_icon_2_pos: Vector2 = Vector2(-10, -12)

var item_id_1: String = ""
var item_id_2: String = ""


func setup(pos: Vector2) -> void:
	self.position = pos	
	clear_items()


func has_empty_slot() -> bool:
	return item_id_1 == "" or item_id_2 == ""


func add_item(item_data: ItemData) -> bool:
	if item_data == null:
		return false

	if item_id_1 == "":
		item_id_1 = item_data.id
		item_icon_1.texture = item_data.icon
		item_icon_1.visible = true
		return true

	if item_id_2 == "":
		item_id_2 = item_data.id
		item_icon_2.texture = item_data.icon
		item_icon_2.visible = true
		return true

	return false


func remove_item(item_id: String) -> bool:
	if item_id_1 == item_id:
		item_id_1 = ""
		item_icon_1.texture = null
		item_icon_1.visible = false
		return true

	if item_id_2 == item_id:
		item_id_2 = ""
		item_icon_2.texture = null
		item_icon_2.visible = false
		return true

	return false


func clear_items() -> void:
	item_id_1 = ""
	item_id_2 = ""

	item_icon_1.texture = null
	item_icon_1.visible = false

	item_icon_2.texture = null
	item_icon_2.visible = false
