# progression_state.gd
class_name ProgressionState
extends Resource

signal category_total_changed(category: StringName, total: int)
signal item_total_changed(definition: ItemDefinition, total: int)
signal overall_total_changed(total: int)

const STATE_NAME: String = "ProgressionState"
const FILE_PATH: String = "res://scripts/progression_state.gd"

@export var category_totals: Dictionary = { }
@export var item_totals: Dictionary = { }
@export var overall_total: int = 0


static func has_progression_state() -> bool:
	return GlobalState.has_state(STATE_NAME)


static func get_or_create_state() -> ProgressionState:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)


static func register_collected(definition: ItemDefinition, amount: int) -> void:
	if not definition or amount <= 0:
		return
	var state: ProgressionState = get_or_create_state()
	var category: StringName = definition.category
	state.category_totals[category] = state.category_totals.get(category, 0) + amount
	state.item_totals[definition] = state.item_totals.get(definition, 0) + amount
	state.overall_total += amount
	state.category_total_changed.emit(category, state.category_totals[category])
	state.item_total_changed.emit(definition, state.item_totals[definition])
	state.overall_total_changed.emit(state.overall_total)
	GlobalState.save()


static func get_category_total(category: StringName) -> int:
	if not has_progression_state():
		return 0
	return get_or_create_state().category_totals.get(category, 0)


static func get_item_total(definition: ItemDefinition) -> int:
	if not has_progression_state():
		return 0
	return get_or_create_state().item_totals.get(definition, 0)


static func get_overall_total() -> int:
	if not has_progression_state():
		return 0
	return get_or_create_state().overall_total


static func reset() -> void:
	var state: ProgressionState = get_or_create_state()
	state.category_totals = { }
	state.item_totals = { }
	state.overall_total = 0
	state.overall_total_changed.emit(0)
	GlobalState.save()
