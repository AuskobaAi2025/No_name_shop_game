extends Node2D
class_name DisplayableFurniture


@export var display_capacity_bonus: int = 0
@export var slot_count: int = 0
@export var slot_positions: Array[Vector2] = []

var item_ids: Array[String] = []
var item_icons: Array[Sprite2D] = []


func setup(target_pos: Vector2) -> void:
	position = target_pos

	_validate_setup()

	_setup_slots()
	clear_items()


func get_display_capacity_bonus() -> int:
	return display_capacity_bonus


func has_empty_slot() -> bool:
	return item_ids.has("")


func add_item(item_data: ItemData) -> bool:
	if item_data == null:
		return false

	for i in item_ids.size():
		if item_ids[i] == "":
			item_ids[i] = item_data.id
			item_icons[i].texture = item_data.icon
			item_icons[i].visible = true
			return true

	return false


func remove_item(item_id: String) -> bool:
	for i in item_ids.size():
		if item_ids[i] == item_id:
			item_ids[i] = ""
			item_icons[i].texture = null
			item_icons[i].visible = false
			return true

	return false


func clear_items() -> void:
	for i in item_ids.size():
		item_ids[i] = ""
		item_icons[i].texture = null
		item_icons[i].visible = false


func _validate_setup() -> void:
	assert(display_capacity_bonus >= 0, "%s: display_capacity_bonus must be >= 0" % name)
	assert(slot_count > 0, "%s: slot_count must be > 0" % name)

	assert(
		slot_positions.size() == slot_count,
		"%s: slot_positions.size() (%d) must match slot_count (%d)"
		% [name, slot_positions.size(), slot_count]
	)


func _setup_slots() -> void:
	_clear_slot_nodes()

	item_ids.clear()
	item_icons.clear()

	for i in slot_count:
		var icon := Sprite2D.new()
		icon.name = "ItemIcon%d" % (i + 1)
		icon.position = slot_positions[i]
		icon.visible = false

		add_child(icon)

		item_icons.append(icon)
		item_ids.append("")


func _clear_slot_nodes() -> void:
	for icon in item_icons:
		if is_instance_valid(icon):
			icon.queue_free()

	item_icons.clear()
