extends CanvasLayer

@export var item_slot_scene: PackedScene

var _slots: Dictionary[ItemDefinition, ItemSlot] = { }
var _inventory: InventoryComponent


func _ready() -> void:
	await get_tree().process_frame
	_initialize()


func _initialize() -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("HUD: no player")
		return
	_inventory = player.get_node_or_null("inventory") as InventoryComponent
	if not _inventory:
		push_error("HUD: no inventory")
		return
	# inventory signals
	_inventory.item_added.connect(_on_item_added)
	_inventory.item_removed.connect(_on_item_removed)
	# Populate
	for def: ItemDefinition in _inventory.items.keys():
		_add_slot(def, _inventory.items[def])
	# Connect every collectable
	for collectable: Node in get_tree().get_nodes_in_group("collectable"):
		if collectable.has_signal("collected"):
			collectable.connect("collected", _inventory.add_item)
		else:
			push_warning(
				"Node in group 'collectable' has no 'collected' signal: ",
				collectable.name,
			)


func _on_item_added(definition: ItemDefinition, new_count: int) -> void:
	if _slots.has(definition):
		_slots[definition].update_count(new_count)
	else:
		_add_slot(definition, new_count)


func _on_item_removed(definition: ItemDefinition, _amount: int) -> void:
	if not _inventory:
		push_error("HUD: no inventory")
		return
	var count: int = _inventory.get_count(definition)
	if count <= 0:
		_slots[definition].queue_free()
		_slots.erase(definition)
	else:
		_slots[definition].update_count(count)


func _add_slot(definition: ItemDefinition, count: int) -> void:
	if not item_slot_scene:
		push_error("HUD: no item_slot_scene")
		return
	var slot_container: Node = Component.find_child_of_type($Control, Container, true)
	if not slot_container:
		push_error("HUD: no slot container found")
		return
	var slot: ItemSlot = item_slot_scene.instantiate() as ItemSlot
	slot_container.add_child(slot)
	slot.set_item(definition, count)
	_slots[definition] = slot
