extends Control

var item_slot_scene: PackedScene = preload("res://Scenes/item_slot.tscn")

@onready var item_list: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/ItemList
@onready var close_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer2/CloseButton

var controller: Node2D = null

var stage_hidden_item_ids: Array[String] = ["1004", "1005", "1001"]


func setup(target_controller: Node2D, hidden_item_ids: Array) -> void:
	controller = target_controller
	stage_hidden_item_ids = hidden_item_ids


func _ready() -> void:
	InventoryManager.inventory_changed.connect(_refresh_ui)
	InventoryManager.setup_inventory(stage_hidden_item_ids)
	_refresh_ui()
		
		
func _on_display_select_pressed(slot: ItemSlot) -> void:
	controller.change_display_item(slot)
	
		
func _refresh_ui() -> void:
	_clear_slots()

	var item_ids: Array = InventoryManager.get_all_item_ids()
	item_ids.sort()

	for item_id in item_ids:
		var item_data: ItemData = InventoryManager.get_item_data(item_id)
		var count: int = InventoryManager.get_count(item_id)

		var slot:ItemSlot = item_slot_scene.instantiate()
		item_list.add_child(slot)
		slot.setup(item_data, count, StoreDisplayItemManager.selected_display_item_ids)
		slot.display_select_pressed.connect(_on_display_select_pressed)
	
	
func _clear_slots() -> void:
	for child in item_list.get_children():
		child.queue_free()


func _on_close_button_pressed() -> void:
	self.queue_free()
