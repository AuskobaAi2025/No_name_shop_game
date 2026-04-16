extends Resource
class_name StageData

# =========================
# Basic
# =========================
@export var stage_id: String = ""
@export var stage_name: String = ""
@export_multiline var stage_description: String = ""

# =========================
# Stop
# =========================
@export var initial_store_level: int = 1
@export var max_store_level: int = 1
@export var entrance_position: Vector2
@export var front_counter_position: Vector2
@export var back_counter_position: Vector2

# =========================
# Customer
# =========================
@export var base_spawn_chance: float = 0.3
@export var customer_wanted_item_ids: Array[String] = []
@export var spawn_interval_multiplier: float = 1.0
@export var customer_wait_tolerance: float = 8.0
@export var customer_satisfaction_bonus: float = 0.0
@export var customer_satisfaction_penalty: float = 0.0

# =========================
# 売れやすさ補正（あると便利）
# =========================
@export var preferred_item_ids: Array[String] = []
@export var unpopular_item_ids: Array[String] = []

# =========================
# 店の拡張条件（あると便利）
# =========================
@export var allow_dresser_1: bool = false
@export var allow_dresser_2: bool = false
