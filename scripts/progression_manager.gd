# progression_manager.gd
extends Node

signal category_total_changed(category: StringName, total: int)

var _totals: Dictionary[StringName, int] = { }


func register_collected(definition: ItemDefinition, amount: int) -> void:
	if not definition:
		return
	var category: StringName = definition.category
	_totals[category] = _totals.get(category, 0) + amount
	category_total_changed.emit(category, _totals[category])


func get_total(category: StringName) -> int:
	return _totals.get(category, 0)
