extends WorkerBase
class_name HiredWorker

var assigned_role: WorkerManager.WorkRole = WorkerManager.WorkRole.NONE
var work_target: Node2D = null
var is_working: bool = false


func start_fixed_work(role: WorkerManager.WorkRole, target: Node2D) -> void:
	if target == null:
		push_error("[PartTimer] work target is null.")
		return

	assigned_role = role
	work_target = target
	is_working = true

	worker_manager.assign_work(worker_id, role, target)
	global_position = shop.get_work_position(target)


func setup_worker(name: String, id: String) -> void:
	super.setup_worker(name, id)
	
	#[Warning] The signal is not for player
	if not worker_manager.worker_registered.is_connected(_on_worker_registered):
		worker_manager.worker_registered.connect(_on_worker_registered)


func stop_work() -> void:
	is_working = false
	assigned_role = WorkerManager.WorkRole.NONE
	work_target = null

	if worker_manager != null and worker_id != "":
		worker_manager.unassign_work(worker_id)


func _on_worker_registered(worker: WorkerBase) -> void:
	visible = false
	

func _on_assignment_changed(changed_worker_id: String) -> void:
	if changed_worker_id != worker_id:
		return

	var target: Node2D = worker_manager.get_worker_target(worker_id)

	if target == null:
		is_working = false
		work_target = null
		assigned_role = WorkerManager.WorkRole.NONE
		visible = false
		return

	work_target = target
	assigned_role = worker_manager.get_worker_role(worker_id)
	is_working = true
	visible = true

	global_position = shop.get_work_position(target)


func can_do_work(role: WorkerManager.WorkRole, target: Node2D) -> bool:
	if target == null:
		return false

	# MVPでは「割り当てられた場所だけで働ける」で十分
	return is_working and assigned_role == role and work_target == target
	
	
