extends Resource
class_name StageData

# =========================
# Basic
# =========================
@export var stage_id: String = ""
@export var stage_name: String = ""
@export_multiline var stage_description: String = ""

# =========================
# Shop
@export var initial_store_lv: int
@export var max_store_lv: int

@export var max_cashier_count: int

@export var entrance_pos: Vector2
@export var front_counter1_pos: Vector2
@export var back_counter1_pos: Vector2
# =========================

# =========================
# Customer
# =========================
@export var base_spawn_chance: float = 0.3
@export var base_spawn_interval: float = 3.0
@export var customer_wait_tolerance: float

# =========================
# Items
# =========================
@export var customer_wanted_item_ids: Array[String] = []
@export var preferred_item_ids: Array[String] = []

# =========================
# 店の拡張条件（あると便利）
# =========================
@export var allow_dresser_1: bool = false
@export var allow_dresser_2: bool = false
