extends PanelContainer
class_name WorkerSlot

signal worker_selected(worker_id: String)

var worker_id: String

@onready var texture_rect: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var worker_name: Label = $MarginContainer/HBoxContainer/VBoxContainer/WorkerName
@onready var worker_role: Label = $MarginContainer/HBoxContainer/VBoxContainer/WorkerRole
@onready var button: Button = $Button


func setup(name: String, id: String, role: String, panel: WorkerPanel) -> void:
	worker_name.text = name
	worker_role.text = role
	
	worker_id = id
	

func _on_button_pressed() -> void:
	worker_selected.emit(worker_id)
