extends Control

var item_slot_scene: PackedScene = preload("res://Scenes/UIs/item_slot.tscn")

@onready var item_list: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/ItemList
@onready var close_button: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer2/CloseButton

var controller: Node2D
var display_item_manager: StoreDisplayItemManager
var inventory_manager: InventoryManager


func setup(target_controller: Node2D, manager: StoreDisplayItemManager, manager2: InventoryManager) -> void:
	controller = target_controller
	display_item_manager = manager
	inventory_manager = manager2


func _ready() -> void:
	inventory_manager.inventory_changed.connect(_refresh_ui)
	_refresh_ui()
		
		
func _on_display_select_pressed(slot: ItemSlot) -> void:
	controller.change_display_item(slot)
	
		
func _refresh_ui() -> void:
	_clear_slots()

	var item_ids: Array = inventory_manager.get_all_item_ids()
	item_ids.sort()
	
	for item_id in item_ids:
		var item_data: ItemData = inventory_manager.get_item_data(item_id)
		var count: int = inventory_manager.get_count(item_id)

		var slot:ItemSlot = item_slot_scene.instantiate()
		item_list.add_child(slot)
		slot.setup(inventory_manager, item_data, count, display_item_manager.selected_display_item_ids)
		slot.display_select_pressed.connect(_on_display_select_pressed)
	
	
func _clear_slots() -> void:
	for child in item_list.get_children():
		child.queue_free()


func _on_close_button_pressed() -> void:
	self.queue_free()
