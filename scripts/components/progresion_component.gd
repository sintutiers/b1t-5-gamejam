# progression_component.gd
class_name ProgressionComponent
extends Component

@onready var collectable: CollectableComponent = get_component(CollectableComponent)


func _ready() -> void:
	if not collectable:
		return
	collectable.collected.connect(_on_collected)


func _on_collected(definition: ItemDefinition, amount: int) -> void:
	ProgressionState.register_collected(definition, amount)
