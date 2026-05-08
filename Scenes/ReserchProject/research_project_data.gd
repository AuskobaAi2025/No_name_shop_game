extends Resource
class_name ResearchProjectData


@export var project_id: String = ""
@export var project_name: String = ""

@export_multiline
var description: String = ""


# Required research points to complete
@export var required_points: float = 100.0


# Items unlocked when completed
@export var unlocked_item_ids: Array[String] = []


# Required completed projects or items before this becomes available
@export var prerequisite_project_ids: Array[String] = []
@export var required_item_ids: Array[String] = []

# category in the FUTURE
# Example:
# "alchemy"
# "food"
# "weapon"
@export var category: String = ""

@export var icon: Texture2D
