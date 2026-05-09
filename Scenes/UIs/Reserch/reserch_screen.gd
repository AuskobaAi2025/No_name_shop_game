extends Control
class_name ReserchScreen


var available_research_projects: Array[ResearchProjectData] = []
var research_manager: ResearchManager

@onready var dynamic_slots: Node = $CenterContainer/PanelContainer/MarginContainer/AvailableResearchPJs/DynamicSlots
@onready var cancel_button: Button = $CenterContainer/PanelContainer/MarginContainer/AvailableResearchPJs/Footer/CancelButton


func setup(manager: ResearchManager,list: Array) -> void:
	research_manager = manager
	update_available_research_projects(list)


func update_available_research_projects(projects: Array[ResearchProjectData]) -> void:
	available_research_projects = projects.duplicate()
	_refresh_project_slots()


func _refresh_project_slots() -> void:
	_clear_project_slots()

	for project in available_research_projects:
		_create_project_slot(project)


func _create_project_slot(project: ResearchProjectData) -> void:
	var slot_instance := Button.new()

	slot_instance.text = project.project_name
	
	slot_instance.pressed.connect(
		_on_project_slot_pressed.bind(project.project_id)
	)
	
	dynamic_slots.add_child(slot_instance)


func _clear_project_slots() -> void:
	for child in dynamic_slots.get_children():
		child.queue_free()
		
		
func _on_cancel_button_pressed() -> void:
	self.queue_free()
	
	
func _on_project_slot_pressed(project_id: String) -> void:
	if research_manager == null:
		push_error("[ResearchScreen] research_manager is null.")
		return

	research_manager.set_target_project(project_id)
