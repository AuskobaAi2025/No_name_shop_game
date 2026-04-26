extends DisplayableFurniture
class_name Cashier


var assigned_operator: Node = null


func assign_operator(operator: Node) -> bool:
	if operator == null:
		return false

	if assigned_operator != null:
		return false

	if not operator.has_method("can_operate_cashier"):
		push_error("%s cannot operate cashier." % operator.name)
		return false

	if not operator.can_operate_cashier():
		return false

	assigned_operator = operator
	return true


func remove_operator(operator: Node) -> bool:
	if operator == null:
		return false

	if assigned_operator != operator:
		return false

	assigned_operator = null
	return true


func has_operator() -> bool:
	return assigned_operator != null


func can_checkout() -> bool:
	return has_operator()


func get_operator() -> Node:
	return assigned_operator
