extends Node2D

@onready var action_gauge: ProgressBar = $ActionGauge

var current_action: String
var action_time: float = 0.0
var is_acting: bool = true
var action_speed: int = 10
var shop: Shop = null


func setup(current_shop: Node2D) -> void:
	shop = current_shop
	position = shop.back_counter1_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_acting:
		return

	action_time += action_speed
	action_gauge.value = action_time
	
	check_action_done()


func check_action_done() -> void:
	if action_time == action_gauge.max_value:
		action_time = 0
		action_gauge.value = 0
		is_acting = false
		action_gauge.visible = false
		
		match current_action:
			"clean":
				print("clean room")
	
	
func start_action(action_name: String) -> void:
	current_action = action_name
	
	match current_action:
		"clean":
			action_gauge.max_value = 5000
			
	action_gauge.value = 0
	is_acting = true
	action_gauge.visible = true
	
