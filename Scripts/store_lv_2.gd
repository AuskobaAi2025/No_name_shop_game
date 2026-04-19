extends Node2D

@onready var dresser_1: Sprite2D = $Interiors/Dresser1
@onready var dresser_2: Sprite2D = $Interiors/Dresser2

#Position
var entrance_pos: Vector2 = Vector2(0, 50)
var front_counter1_pos: Vector2 = Vector2(0, 0)
var back_counter1_pos: Vector2 = Vector2(0, -40)

#Cashier
var initial_cashier_count: int = 1
var max_cashier_count: int = 1
