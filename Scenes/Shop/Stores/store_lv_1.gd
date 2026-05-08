extends StoreBase
class_name StoreLv1

# Positions
@onready var store_entrance_pos: Marker2D = $KeyPositions/StoreEntrancePos
@onready var cashier_pos_1: Marker2D = $KeyPositions/CashierPos1
@onready var customer_line_start_pos: Marker2D = $KeyPositions/CustomerLineStartPos

	
func setup_config() -> void:
	cashier_positions = [Vector2(0, -16)]
	
	max_dresser_count = 0
	initial_cashier_count = 1
	max_cashier_count = 1
	
	entrance_pos = store_entrance_pos.position
	line_start_pos = customer_line_start_pos.position
	

func add_dresser() -> bool:
	print("[StoreLv1] Failed: StoreLv1 cannot place dressers.")
	return false
