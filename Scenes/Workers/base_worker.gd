extends CharacterBody2D
class_name WorkerBase

var worker_id: String = ""
var worker_name: String = ""

var speed: float = 100.0
var exp: int = 0 #Unknown, delete if it is not used

var shop: Shop = null
var worker_manager: WorkerManager

func setup(current_shop: Shop, manager: WorkerManager) -> void:
	shop = current_shop
	worker_manager = manager


func setup_worker(name: String, id: String) -> void:
	if id == "":
		push_error("[WorkerBase] worker_id is empty.")
		return
		
	worker_name = name
	worker_id = id
	
	if not worker_manager.assignment_changed.is_connected(_on_assignment_changed):
		worker_manager.assignment_changed.connect(_on_assignment_changed)
		

func get_worker_id() -> String:
	return worker_id


func is_worker() -> bool:
	return true


func update_position_by_assignment() -> void:
	var target: Node2D = worker_manager.get_worker_target(worker_id)

	if target == null:
		push_error("[WorkerBase] work target is null. worker_id=%s" % worker_id)
		return

	position = shop.get_work_position(target)
	
	
func _on_assignment_changed(changed_worker_id: String) -> void:
	if changed_worker_id != worker_id:
		return

	update_position_by_assignment()
