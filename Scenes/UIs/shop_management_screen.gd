extends Control


@onready var next_day: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/NextDay
@onready var recruit_staff: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RecruitStaff

var game_controller: Node2D
var shop_instance: Shop

func setup(controller: Node2D, shop: Shop) -> void:
	game_controller = controller
	shop_instance = shop
	
	
func _on_next_day_pressed() -> void:
	print("Next day....")
	game_controller.game_start()
	
	self.queue_free()


func _on_recruit_staff_pressed() -> void:
	game_controller.spawn_worker()
	print("Recruited a staff")


func _on_add_dresser_pressed() -> void:
	if shop_instance.try_add_dresser():
		print("Added a dresser")
	else:
		print("Failed to add a dresser")


func _on_add_cashier_pressed() -> void:
	if shop_instance.try_add_cashier():
		print("Added a cashier")
	else:
		print("Failed to add a cashier")


func _on_choose_reseach_pressed() -> void:
	game_controller.show_reserach_screen()
	print("Open Research UI [Future]")


func _on_store_lv_up_pressed() -> void:
	print("Storelv increased")
	shop_instance.leveup_store()
