extends Control
class_name WorkerAssignmentWindow


var worker_manager: WorkerManager
var shop: Shop
var parent_panel: WorkerPanel
var worker_id: String = ""

func setup(
	target_worker_manager: WorkerManager,
	target_shop: Shop,
	panel: WorkerPanel,
	selected_worker_id: String
	) -> void:
	
	worker_manager = target_worker_manager
	shop = target_shop
	parent_panel = panel
	worker_id = selected_worker_id


func _on_cashier_assign_button_pressed() -> void:
	var target_cashier: Node = shop.get_unassigned_cashier(worker_manager)

	if target_cashier == null:
		push_error("[WorkerAssignmentWindow] No available cashier.")
		return

	worker_manager.assign_work(
		worker_id,
		WorkerManager.WorkRole.CASHIER,
		target_cashier
	)
	
	parent_panel.refresh_all_workers()
	
	var enable_blocking: bool = false
	parent_panel.set_input_blocking(enable_blocking)
	self.queue_free()


func _on_reseacher_assign_button_pressed() -> void:
	print("Assign reseacher role [FUTURE]")


func _on_cancel_button_pressed() -> void:
	var enable_blocking: bool = false
	parent_panel.set_input_blocking(enable_blocking)
	self.queue_free()
