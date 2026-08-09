# inventory_component.gd
### not sure i need this, im still setting systems up
## decided to use this as dependency for future exensibility
class_name InventoryComponent
extends Component

signal item_added(definition: ItemDefinition, count: int)
signal item_removed(definition: ItemDefinition, count: int)

var items: Dictionary[ItemDefinition, int] = { }


func add_item(definition: ItemDefinition, amount: int = 1) -> void:
	if not definition:
		return
	var new_count: int = items.get(definition, 0) + amount
	if definition.stackable:
		new_count = min(new_count, definition.max_stack)
	items[definition] = new_count
	item_added.emit(definition, new_count)


func remove_item(definition: ItemDefinition, amount: int = 1) -> bool:
	var current: int = items.get(definition, 0)
	if current < amount:
		return false
	var new_count: int = current - amount
	if new_count <= 0:
		items.erase(definition)
	else:
		items[definition] = new_count
	item_removed.emit(definition, amount)
	return true


func get_count(definition: ItemDefinition) -> int:
	return items.get(definition, 0)
