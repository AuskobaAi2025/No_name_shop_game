extends Node
class_name WorkerManager

signal worker_registered(worker: WorkerBase)
signal worker_removed(worker_id: String)
signal assignment_changed(worker_id: String)


enum WorkRole {
	NONE,
	CASHIER,
	CLEANER,
	STOCKER,
    RESEARCHER,
}


var workers: Dictionary = {}
# key: worker_id
# value: WorkerBase

var assignments: Dictionary = {}
# key: worker_id
# value: {
#	"role": WorkRole,
#	"target": Node
# }


func register_worker(worker: WorkerBase) -> void:
	if worker == null:
		push_error("[WorkerManager] worker is null.")
		return

	if worker.worker_id == "":
		push_error("[WorkerManager] worker_id is empty.")
		return

	if workers.has(worker.worker_id):
		push_warning("[WorkerManager] Worker already registered: %s" % worker.worker_id)

	workers[worker.worker_id] = worker
	emit_signal("worker_registered", worker)


func remove_worker(worker_id: String) -> void:
	if worker_id == "":
		return

	if not workers.has(worker_id):
		return

	workers.erase(worker_id)
	assignments.erase(worker_id)

	emit_signal("worker_removed", worker_id)


func assign_work(worker_id: String, role: WorkRole, target: Node = null) -> void:
	if not workers.has(worker_id):
		push_error("[WorkerManager] Worker not found: %s" % worker_id)
		return

	if role == WorkRole.NONE:
		unassign_work(worker_id)
		return

	assignments[worker_id] = {
		"role": role,
		"target": target,
	}

	emit_signal("assignment_changed", worker_id)


func unassign_work(worker_id: String) -> void:
	if not assignments.has(worker_id):
		return

	assignments.erase(worker_id)
	emit_signal("assignment_changed", worker_id)


func get_worker_role(worker_id: String) -> WorkRole:
	var assignment: Dictionary = _get_assignment(worker_id)
	return assignment.get("role", WorkRole.NONE)


func get_worker_target(worker_id: String) -> Node:
	var assignment: Dictionary = _get_assignment(worker_id)
	return assignment.get("target", null)


func has_assigned_worker(role: WorkRole, target: Node = null) -> bool:
	for assignment in assignments.values():
		if assignment.get("role") != role:
			continue

		if target != null and assignment.get("target") != target:
			continue

		return true

	return false


func get_worker(worker_id: String) -> WorkerBase:
	return workers.get(worker_id, null)


func get_all_workers() -> Array[WorkerBase]:
	var result: Array[WorkerBase] = []

	for worker in workers.values():
		if worker is WorkerBase:
			result.append(worker)

	return result
	
	
func enter_management_mode() -> void:
	for worker in get_all_workers():
		worker.visible = false


func enter_gameplay_mode() -> void:
	for worker in get_all_workers():
		worker.visible = _has_assignment(worker.worker_id)


####PRIVATE FUNCTIONS####


func _get_assignment(worker_id: String) -> Dictionary:
	return assignments.get(worker_id, {
		"role": WorkRole.NONE,
		"target": null,
	})


func _has_assignment(worker_id: String) -> bool:
	return assignments.has(worker_id)
