extends Node
class_name WorkerSpawner

enum WorkerType {
	PLAYER,
	HIRED_WORKER,
}

var player_scene: PackedScene = preload("res://Scenes/Workers/Player/player.tscn")
var hired_worker_scene: PackedScene = preload("res://Scenes/Workers/HiredWorker/hired_worker.tscn")


var workers_root: Node2D
var shop: Shop
var worker_manager: WorkerManager

@onready var workers: Node = $Workers


func setup(target_shop: Shop, target_worker_manager: WorkerManager) -> void:
	shop = target_shop
	worker_manager = target_worker_manager


func spawn_player(worker_id: String, worker_name: String) -> Player:
	return _spawn_worker(WorkerType.PLAYER, worker_id, worker_name) as Player


func spawn_hired_worker(worker_id: String, worker_name: String) -> HiredWorker:
	return _spawn_worker(WorkerType.HIRED_WORKER, worker_id, worker_name) as HiredWorker


func delete_worker_by_id(worker_id: String) -> void:
	if worker_manager == null:
		push_error("[WorkerSpawner] worker_manager is null.")
		return

	var worker: WorkerBase = worker_manager.get_worker(worker_id)

	if worker == null:
		push_error("[WorkerSpawner] worker not found.")
		return

	worker_manager.remove_worker(worker_id)

	worker.queue_free()


func _spawn_worker(
	worker_type: WorkerType,
	worker_id: String,
	worker_name: String
) -> WorkerBase:
	var worker: WorkerBase = null

	match worker_type:
		WorkerType.PLAYER:
			worker = player_scene.instantiate()
		WorkerType.HIRED_WORKER:
			worker = hired_worker_scene.instantiate()

	if worker == null:
		push_error("[WorkerSpawner] Failed to instantiate worker.")
		return null

	workers.add_child(worker)

	worker.setup(shop, worker_manager)
	worker.setup_worker(worker_name, worker_id)

	worker_manager.register_worker(worker)

	return worker
