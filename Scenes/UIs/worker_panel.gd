extends Control
class_name WorkerPanel


var worker_slot_scene: PackedScene = preload("res://Scenes/UIs/worker_slot.tscn")
var assignment_window_scene: PackedScene = preload("res://Scenes/UIs/worker_assignment_window.tscn")
var manager: WorkerManager
var shop: Shop

@onready var workers_list: VBoxContainer = $HBoxContainer/ListContainer/MarginContainer/VboxContainer/MarginContainer/ScrollContainer/WorkersList
@onready var input_blocker: Panel = $InputBlocker


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("close"):
		_close_panel()


func setup(target_manager: WorkerManager, target_shop: Shop) -> void:
	manager = target_manager
	shop = target_shop
	refresh_all_workers()
	get_tree().paused = true
	
	input_blocker.visible = false
	
	
func refresh_all_workers() -> void:
	if manager == null:
		push_error("[WorkerPanel] manager is null.")
		return

	_clear_worker_slots()

	var workers: Array[WorkerBase] = manager.get_all_workers()

	for worker in workers:
		var worker_slot_instance: WorkerSlot = worker_slot_scene.instantiate()
		workers_list.add_child(worker_slot_instance)

		var worker_role: WorkerManager.WorkRole = manager.get_worker_role(worker.worker_id)
		var worker_role_text: String = _get_role_text(worker_role)

		worker_slot_instance.setup(worker.worker_name, worker.worker_id, worker_role_text, self)
		
		if not worker_slot_instance.worker_selected.is_connected(_on_worker_selected):
			worker_slot_instance.worker_selected.connect(_on_worker_selected)


func set_input_blocking(enabled: bool = false) -> void:
	if enabled:
		input_blocker.visible = true
		return
	
	input_blocker.visible = false


func _close_panel() -> void:
	get_tree().paused = false
	queue_free()


func _clear_worker_slots() -> void:
	for child in workers_list.get_children():
		child.queue_free()


func _get_role_text(role: WorkerManager.WorkRole) -> String:
	match role:
		WorkerManager.WorkRole.NONE:
			return "None"
		WorkerManager.WorkRole.CASHIER:
			return "Cashier"
		WorkerManager.WorkRole.CLEANER:
			return "Cleaner"
		WorkerManager.WorkRole.STOCKER:
			return "Stocker"
		_:
			return "Unknown"


func _on_worker_selected(worker_id: String) -> void:
	var enable_blocker: bool = true
	set_input_blocking(enable_blocker)
	var window_instance = assignment_window_scene.instantiate()
	add_child(window_instance)
	window_instance.setup(manager, shop, self, worker_id)
	
	
