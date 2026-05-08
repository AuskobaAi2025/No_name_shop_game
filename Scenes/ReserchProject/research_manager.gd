extends Node
class_name ResearchManager

signal research_started(project_id: String)
signal research_progress_changed(project_id: String, current_progress: float, required_points: float)
signal research_completed(project_data: ResearchProjectData)


@export var research_projects: Array[ResearchProjectData] = []

var project_database: Dictionary = {}
# key: project_id
# value: ResearchProjectData

var completed_project_ids: Array[String] = []

var current_project_id: String = ""
var current_progress: float = 0.0

# Base research power per worker. This is the amount of research points a single
# worker contributes per second before applying personality modifiers. If no
# workers are assigned to research, this value is used to progress research at
# a minimal pace so projects can still be completed.
var base_research_power: float = 50.0
var is_researching: bool = false

# Reference to the WorkerManager so we can query which workers are assigned
# to research. Provided via setup().
var worker_manager: WorkerManager

var inventory_manager: InventoryManager


func _ready() -> void:
	register_projects()





func setup(target_inventory_manager: InventoryManager, target_worker_manager: WorkerManager = null) -> void:
    inventory_manager = target_inventory_manager
    worker_manager = target_worker_manager


func register_projects() -> void:
	project_database.clear()

	for project in research_projects:
		if project == null:
			push_error("[ResearchManager] ResearchProjectData is null.")
			continue

		if project_database.has(project.project_id):
			push_error("[ResearchManager] Duplicate project_id: %s" % project.project_id)
			continue

		project_database[project.project_id] = project


func start_project(project_id: String) -> void:
	if not can_start_project(project_id):
		return

	current_project_id = project_id
	current_progress = 0.0
	is_researching = true

	emit_signal("research_started", current_project_id)


func process_research(delta: float) -> void:
	if not is_researching:
		return

	if current_project_id == "":
		return

	var project: ResearchProjectData = get_project_data(current_project_id)
	if project == null:
		push_error("[ResearchManager] Current project data not found: %s" % current_project_id)
	# Compute research progress. If workers have been assigned to the RESEARCHER
	# role their combined contributions (base_research_power * personality
	# multiplier) are summed. If no researchers are assigned, a single unit
	# of base_research_power is used to provide slow baseline progress.
	var power: float = 0.0
	var found_researchers: bool = false
	if worker_manager != null:
		# Sum contributions from all workers assigned to research
		for worker in worker_manager.get_all_workers():
			if worker_manager.get_worker_role(worker.worker_id) == WorkerManager.WorkRole.RESEARCHER:
				found_researchers = true
				var multiplier: float = 1.0
				if worker.has_method("get_research_multiplier"):
					multiplier = worker.get_research_multiplier()
				power += base_research_power * multiplier
	if not found_researchers:
		# Default to base power if no researchers are assigned
		power = base_research_power

	current_progress += power * delta
		"research_progress_changed",
		current_project_id,
		current_progress,
		project.required_points
	)

	if current_progress >= project.required_points:
		complete_current_project()


func complete_current_project() -> void:
	if current_project_id == "":
		return

	var project: ResearchProjectData = get_project_data(current_project_id)
	if project == null:
		push_error("[ResearchManager] Cannot complete project. Data not found: %s" % current_project_id)
		stop_research()
		return

	if not completed_project_ids.has(current_project_id):
		completed_project_ids.append(current_project_id)

	current_progress = project.required_points
	is_researching = false

	emit_signal("research_completed", project)

	current_project_id = ""
	current_progress = 0.0
	
	
func stop_research() -> void:
	is_researching = false
	current_project_id = ""
	current_progress = 0.0


func can_start_project(project_id: String) -> bool:
	if is_researching:
		print("[ResearchManager] Already researching.")
		return false

	if not project_database.has(project_id):
		push_error("[ResearchManager] Project not found: %s" % project_id)
		return false

	if completed_project_ids.has(project_id):
		print("[ResearchManager] Project already completed: %s" % project_id)
		return false

	var project: ResearchProjectData = project_database[project_id]

	for prerequisite_id in project.prerequisite_project_ids:
		if not completed_project_ids.has(prerequisite_id):
			print(
				"[ResearchManager] Missing prerequisite: %s for project: %s"
				% [prerequisite_id, project_id]
			)
			return false

	if not _has_required_items(project):
		return false

	return true


func get_project_data(project_id: String) -> ResearchProjectData:
	if not project_database.has(project_id):
		return null

	return project_database[project_id]


func get_available_projects() -> Array[ResearchProjectData]:
	var result: Array[ResearchProjectData] = []

	for project_id in project_database.keys():
		if can_show_project(project_id):
			result.append(project_database[project_id])

	return result


func can_show_project(project_id: String) -> bool:
	if not project_database.has(project_id):
		return false

	if completed_project_ids.has(project_id):
		return true

	var project: ResearchProjectData = project_database[project_id]

	for prerequisite_id in project.prerequisite_project_ids:
		if not completed_project_ids.has(prerequisite_id):
			return false

	return true


func is_project_completed(project_id: String) -> bool:
	return completed_project_ids.has(project_id)


func get_save_data() -> Dictionary:
	return {
		"completed_project_ids": completed_project_ids.duplicate(),
		"current_project_id": current_project_id,
		"current_progress": current_progress,
		"is_researching": is_researching,
	}


func load_from_data(data: Dictionary) -> void:
	completed_project_ids.clear()

	if data.has("completed_project_ids"):
		for project_id in data["completed_project_ids"]:
			completed_project_ids.append(project_id)

	current_project_id = data.get("current_project_id", "")
	current_progress = data.get("current_progress", 0.0)
	is_researching = data.get("is_researching", false)

	if current_project_id != "" and not project_database.has(current_project_id):
		push_error("[ResearchManager] Loaded current_project_id does not exist: %s" % current_project_id)
		stop_research()
		
		
func _has_required_items(project: ResearchProjectData) -> bool:
	if inventory_manager == null:
		push_error("[ResearchManager] inventory_manager is null.")
		return false

	for item_id in project.required_item_ids:
		if not inventory_manager.is_item_available(item_id):
			print(
				"[ResearchManager] Missing required item: %s for project: %s"
				% [item_id, project.project_id]
			)
			return false

	return true
		
