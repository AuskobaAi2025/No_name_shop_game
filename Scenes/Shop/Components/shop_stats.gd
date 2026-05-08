extends Node
class_name ShopStats

var daily_customer_count: int = 0
var daily_purchase_success_count: int = 0
var daily_satisfied_count: int = 0
var daily_normal_count: int = 0
var daily_dissatisfied_count: int = 0
var daily_total_satisfaction: float = 0.0
var daily_average_satisfaction: float = 0.0
var shop_reputation: float = 0.0


func register_customer_visit() -> void:
	daily_customer_count += 1


func report_customer_result(satisfaction_score: float, bought_successfully: bool) -> void:
	daily_total_satisfaction += satisfaction_score

	if bought_successfully:
		daily_purchase_success_count += 1

	if satisfaction_score >= 80.0:
		daily_satisfied_count += 1
	elif satisfaction_score >= 40.0:
		daily_normal_count += 1
	else:
		daily_dissatisfied_count += 1

	update_daily_average_satisfaction()


func update_daily_average_satisfaction() -> void:
	var total_finished_customers := daily_satisfied_count + daily_normal_count + daily_dissatisfied_count
	
	if total_finished_customers <= 0:
		daily_average_satisfaction = 0.0
		return

	daily_average_satisfaction = daily_total_satisfaction / float(total_finished_customers)


func apply_daily_reputation_result() -> void:
	shop_reputation += (daily_average_satisfaction - 50.0) * 0.05
	shop_reputation = clamp(shop_reputation, -100.0, 100.0)


func get_spawn_bonus_from_reputation() -> float:
	return shop_reputation * 0.002
	
	
