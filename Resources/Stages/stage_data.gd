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
@export var forbidden_item_ids: Array[String] = []
@export var initial_unlocked_item_ids: Array[String] = []
@export var customer_wanted_item_ids: Array[String] = []
@export var preferred_item_ids: Array[String] = []
