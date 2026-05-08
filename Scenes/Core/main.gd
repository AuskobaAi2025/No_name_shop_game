extends Node2D

@onready var game_controller: Node2D = $GameController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.store_name = "AAA"
	Global.date = 1
	Global.money = 1000
	Global.customer_num_daily = 10
	Global.customer_num_total = 100
	
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		game_controller.game_start()
