extends PanelContainer
class_name ItemSlot

signal display_select_pressed(slot: ItemSlot)

var item_id: String
var is_selected: bool = false


@onready var icon: TextureRect = $HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Icon
@onready var item_name: Label = $HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/CenterContainer/VBoxContainer/ItemName
@onready var amount_gauge: ProgressBar = $HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/CenterContainer/VBoxContainer/AmountGauge
@onready var restock_button: Button = $HBoxContainer/MarginContainer2/RestockButton
@onready var display_select_button: Button = $HBoxContainer/PanelContainer/DisplaySelectButton
@onready var item_panel_container: PanelContainer = $HBoxContainer/PanelContainer


@export var normal_theme: Theme
@export var selected_theme: Theme

func setup(item_data: ItemData, count: int, selected_item_list: Array) -> void:
	if item_data == null:
		item_name.id = ""
		item_name.text = "Unknown"
		amount_gauge.value = count
		icon.texture = null
		return
		
	item_id = item_data.id
	item_name.text = item_data.item_name
	amount_gauge.value = count
	icon.texture = item_data.icon
		
	for selected_id in selected_item_list:
		if item_id == selected_id:
			set_selected(true)


func _ready() -> void:
	if not display_select_button.pressed.is_connected(_on_display_select_button_pressed):
		display_select_button.pressed.connect(_on_display_select_button_pressed)


func _on_restock_button_pressed() -> void:
	InventoryManager.add_item(item_id, 5)
	
	
func _on_display_select_button_pressed() -> void:
	display_select_pressed.emit(self)
	
	
func set_selected(value: bool) -> void:
	if is_selected == value:
		return

	is_selected = value
	_update_style()


func _update_style() -> void:
	var target_theme: Theme = selected_theme if is_selected else normal_theme
	if target_theme == null:
		return

	var style: StyleBox = target_theme.get_stylebox("panel", "PanelContainer")
	if style != null:
		item_panel_container.add_theme_stylebox_override("panel", style)
