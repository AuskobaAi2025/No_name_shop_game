extends Control
class_name OperationUI

#Status bar
@onready var store_name_text: Label = $StatusBar/HBoxContainer/VBoxContainer2/StoreNameText
@onready var date_text: Label = $StatusBar/HBoxContainer/VBoxContainer2/DateText
@onready var total_sales_text: Label = $StatusBar/HBoxContainer/VBoxContainer2/TotalSalesText
@onready var total_customers_text: Label = $StatusBar/HBoxContainer/VBoxContainer2/TotalCustomersText

#Menu list bar
@onready var menu_list_bar: Control = $MenuListBar
@onready var message_panel: PanelContainer = $MenuListBar/MessagePanel
@onready var button_list_bar: PanelContainer = $MenuListBar/ButtonListBar

@onready var comment_container: VBoxContainer = $CustomerVoiceBar/MarginContainer/VBoxContainer/CommentContainer

var game_controller: Node2D


func setup(controller: Node2D) -> void:
	game_controller = controller


func _ready() -> void:
	# adjust a message pos for menu bar.
	message_panel.position = button_list_bar.position + Vector2(0, -55)


func _process(_delta: float) -> void:
	_update_status_bar()


func _update_status_bar() -> void:
	store_name_text.text = ": " + Global.store_name
	date_text.text = ": " + str(Global.date)
	total_sales_text.text = ": " + str(Global.money)
	total_customers_text.text = ": " + str(Global.customer_num_daily)

	
func add_comment(target_comment) -> void:

	var label := Label.new()
	label.text = target_comment

	comment_container.add_child(label)

	# 10件を超えたら一番古いものを削除
	if comment_container.get_child_count() > 10:
		var oldest := comment_container.get_child(0)
		oldest.queue_free()


func _on_restock_button_pressed() -> void:
	game_controller.show_inventory_menu()
	

func _on_clean_room_button_pressed() -> void:
	game_controller.start_clean()


func _on_worker_info_button_pressed() -> void:
	game_controller.show_worker_panel()


func _on_open_shop_button_pressed() -> void:
	game_controller.open_shop()


func _on_close_shop_button_pressed() -> void:
	game_controller.close_shop()


func _on_next_day_button_pressed() -> void:
	game_controller.proceed_next_day()
