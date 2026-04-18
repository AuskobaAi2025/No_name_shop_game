extends Node2D

@onready var customer_spawner: CustomerSpawner = $Shop/CustomerSpawner
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var shop: Shop = $Shop

var player_scene: PackedScene = preload("res://Scenes/player.tscn")
var ui_scene: PackedScene = preload("res://Scenes/inventory_ui.tscn")
var player_instance: Node2D
var ui_instance: Control


func _ready() -> void:
	Global.base_chance = 0.5
	Global.store_fame = 0.1
	
	game_start()


func _process(delta: float) -> void:
	_hundle_input(delta, player_instance)
	
	if ui_instance == null:
		if not player_instance.is_acting:
			shop.is_casher1_available = true


func _hundle_input(delta: float, player_instance) -> void:
	if Input.is_action_just_pressed("test"):
		if ui_instance != null:
			shop.is_casher1_available = true
			ui_instance.queue_free()
		pass


func game_start() -> void:
	shop.setup()
	
	customer_spawner.setup(shop)
	
	player_instance = player_scene.instantiate()
	player_instance.setup(shop)
	add_child(player_instance)


func _on_restock_button_pressed() -> void:
	if ui_instance:
		return
		
	ui_instance = ui_scene.instantiate()
	ui_instance.setup(shop)
	
	canvas_layer.add_child(ui_instance)
	
	shop.is_casher1_available = false


func _on_clean_room_button_pressed() -> void:
	player_instance.start_action("clean")
	shop.is_casher1_available = false


func _on_info_button_pressed() -> void:
	print("Show info")


func _on_open_shop_button_pressed() -> void:
	shop.is_open = true
	print("Open shop")


func _on_close_shop_button_pressed() -> void:
	shop.is_open = false
	print("Close shop")


func _on_next_day_button_pressed() -> void:
	print("Next day...")
	shop.apply_daily_reputation_result()
	Global.date += 1
