extends Node2D
class_name StoreBase

@onready var interiors: Node2D = $Interiors
@onready var cashiers: Node = $Interiors/Cashiers

# Dresser
var dresser_scene: PackedScene = preload("res://Scenes/Shop/Interiors/dresser.tscn")
var dresser_instances: Array[Dresser] = []
var max_dresser_count: int = -100

# Cashier
var cashier_scene: PackedScene = preload("res://Scenes/Shop/Interiors/cashier.tscn")
var cashier_instances: Array[Cashier] = []

var cashier_positions: Array[Vector2]
var initial_cashier_count: int = -100
var max_cashier_count: int = -100

var display_item_manager: StoreDisplayItemManager
var inventory_manager: InventoryManager
var entrance_pos: Vector2

@export var max_line_size: int = 3
@export var line_start_pos: Vector2 = Vector2(-100, -100)
@export var line_offset: Vector2 = Vector2(0, 24)

func _ready() -> void:
	setup_config()
	validate_config()


func setup(manager: StoreDisplayItemManager, manager2: InventoryManager) -> void:
	display_item_manager = manager
	inventory_manager = manager2
	add_cashier()


func setup_config() -> void:
	push_error("[StoreBase] setup_config() must be overridden.")


func validate_config() -> void:
	if max_dresser_count == -100:
		push_error("[%s] max_dresser_count is not configured." % name)

	if initial_cashier_count == -100:
		push_error("[%s] initial_cashier_count is not configured." % name)
		
	if max_cashier_count == -100:
		push_error("[%s] max_cashier_count is not configured." % name)
		
	if line_start_pos == Vector2(-100, -100):
		push_error("[%s] line_start_pos is not configured." % name)

####CASHIERS####

func add_cashier() -> bool:
	if get_cashier_count() >= max_cashier_count:
		print("[BaseStore] Failed: Cashier count reached max.")
		return false

	var cashier: Cashier =  cashier_scene.instantiate()
	interiors.add_child(cashier)

	var index: int = get_cashier_count()
	cashier.setup(cashier_positions[index])

	cashier_instances.append(cashier)
	display_item_manager.update_cashier_count()

	return true


func get_cashier_count() -> int:
	return get_cashiers().size()


func get_cashier_slots() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for cashier in get_cashiers():
		result.append({
			"cashier": cashier,
			"customer_pos": cashier.get_customer_stand_pos(),
			"worker_pos": cashier.get_worker_stand_pos(),
		})

	return result


func get_cashiers() -> Array[Node]:
	var result: Array[Node] = []

	for cashier in cashier_instances:
		if is_instance_valid(cashier):
			result.append(cashier)

	return result


####DRESSER####

func get_dresser_count() -> int:
	return get_dressers().size()


func add_dresser() -> bool:
	print("[StoreBase] Failed: No available dresser slot.")
	return false


func get_dressers() -> Array[Dresser]:
	var result: Array[Dresser] = []

	for dresser in dresser_instances:
		if is_instance_valid(dresser):
			result.append(dresser)

	return result


####DISPLAY####

func add_display_item(item_id: String) -> void:
	var item_data: ItemData = inventory_manager.get_item_data(item_id)
	if item_data == null:
		return

	for furniture in get_displayable_furnitures():
		if furniture.has_empty_slot():
			furniture.add_item(item_data)
			return

	print("[Store] No empty display slot.")


func remove_display_item(item_id: String) -> void:
	for cashier in get_cashiers():
		if cashier.remove_item(item_id):
			return

	for dresser in get_dressers():
		if dresser.remove_item(item_id):
			return


func clear_display_items() -> void:
	for cashier in get_cashiers():
		cashier.clear_items()

	for dresser in get_dressers():
		dresser.clear_items()

####OTHERS####

func get_displayable_furnitures() -> Array[DisplayableFurniture]:
	var result: Array[DisplayableFurniture] = []

	for cashier in get_cashiers():
		result.append(cashier)

	for dresser in get_dressers():
		result.append(dresser)

	return result


func get_max_line_size() -> int:
	return max_line_size
	
	
func get_line_position(index: int) -> Vector2:
	return global_position + line_start_pos + line_offset * index

	
	
