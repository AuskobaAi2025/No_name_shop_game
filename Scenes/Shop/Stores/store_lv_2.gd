extends StoreBase
class_name StoreLv2

# Positions
@onready var store_entrance_pos: Marker2D = $KeyPositions/StoreEntrancePos
@onready var cashier_pos_1: Marker2D = $KeyPositions/CashierPos1
@onready var customer_line_start_pos: Marker2D = $KeyPositions/CustomerLineStartPos

var dresser_positions: Array[Vector2] = [
	Vector2(-40, -64),
	Vector2(40, -64)
]


func setup_config() -> void:
	cashier_positions = [Vector2(0, -16)]
	
	max_dresser_count = 2
	initial_cashier_count = 1
	max_cashier_count = 1
	
	entrance_pos = store_entrance_pos.position
	line_start_pos = customer_line_start_pos.position


func add_dresser() -> bool:
	if get_dresser_count() >= max_dresser_count:
		print("[StoreLv2] Failed: Dresser count reached max.")
		return false

	var dresser: Dresser = dresser_scene.instantiate()
	interiors.add_child(dresser)

	var index: int = get_dresser_count()
	dresser.setup(dresser_positions[index])

	dresser_instances.append(dresser)
	display_item_manager.update_dresser_count()

	return true
