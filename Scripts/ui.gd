extends Control

#Status bar
@onready var store_name_text: Label = $StatusBar/HBoxContainer/VBoxContainer2/StoreNameText
@onready var date_text: Label = $StatusBar/HBoxContainer/VBoxContainer2/DateText
@onready var total_sales_text: Label = $StatusBar/HBoxContainer/VBoxContainer2/TotalSalesText
@onready var total_customers_text: Label = $StatusBar/HBoxContainer/VBoxContainer2/TotalCustomersText


#Menu list bar
@onready var menu_list_bar: Control = $MenuListBar
@onready var message_panel: PanelContainer = $MenuListBar/MessagePanel
@onready var button_list_bar: PanelContainer = $MenuListBar/ButtonListBar


func _ready() -> void:
	# adjust a message pos for menu bar.
	message_panel.position = button_list_bar.position + Vector2(0, -55)


func _process(delta: float) -> void:
	_update_status_bar()


func _update_status_bar() -> void:
	store_name_text.text = ": " + Global.store_name
	date_text.text = ": " + str(Global.date)
	total_sales_text.text = ": " + str(Global.sales)
	total_customers_text.text = ": " + str(Global.customer_num_daily)
