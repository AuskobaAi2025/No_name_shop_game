extends Control

var item_slot_scene: PackedScene = preload("res://Scenes/item_slot.tscn")

@onready var item_list: VBoxContainer = $CenterContainer/PanelContainer/HBoxContainer/MarginContainer/ItemList
@onready var texture_button: TextureButton = $CenterContainer/PanelContainer/HBoxContainer/TextureButton

var shop: Shop = null

func setup(target_shop: Shop) -> void:
	shop = target_shop


func _ready() -> void:
	InventoryManager.inventory_changed.connect(_refresh_ui)
	
	var item_ids: Array = Global.item_candidates
	
	for id in item_ids:
		InventoryManager.add_item(id, 0)
		
		
func _on_display_select_pressed(slot: ItemSlot) -> void:
	if slot.item_id == "":
		return

	if slot.is_selected:
		slot.set_selected(false)
		shop.selected_display_item_ids.erase(slot.item_id)
		print("Display removed: ", slot.item_id)
		return

	if shop.selected_display_item_ids.size() >= shop.max_display_item_count:
		print("Display limit reached")
		return

	slot.set_selected(true)
	shop.selected_display_item_ids.append(slot.item_id)
	print("Display added: ", slot.item_id)

		
func _refresh_ui() -> void:
	_clear_slots()

	var item_ids: Array = InventoryManager.get_all_item_ids()
	item_ids.sort()

	for item_id in item_ids:
		var item_data: ItemData = InventoryManager.get_item_data(item_id)
		var count: int = InventoryManager.get_count(item_id)

		var slot:ItemSlot = item_slot_scene.instantiate()
		item_list.add_child(slot)
		slot.setup(item_data, count, shop.selected_display_item_ids)
		slot.display_select_pressed.connect(_on_display_select_pressed)
	
	
func _clear_slots() -> void:
	for child in item_list.get_children():
		child.queue_free()


func _on_texture_button_pressed() -> void:
	self.queue_free()
