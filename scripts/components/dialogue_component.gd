# dialogue_component.gd
class_name DialogueComponent
extends Component
## the audio/talk stuff is a hack, need to wire it propperly it into the current system.

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var talk_sound: AudioStream

var _movement: MovementComponent

@onready var interactable: Interactable = get_component(Interactable) as Interactable
@onready var player: AudioStreamPlayer2D = %AudioStreamPlayer2D


func _ready() -> void:
	assert(interactable, "Interactable needed.")
	if not dialogue_resource:
		push_warning("No DialogueResource.")
	interactable.interacted.connect(_on_interacted)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _exit_tree() -> void:
	if interactable and interactable.interacted.is_connected(_on_interacted):
		interactable.interacted.disconnect(_on_interacted)
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)


func play_talk_letter(letter: String, letter_index: int) -> void:
	if [" ", "."].has(letter):
		return
	if letter_index % 2 == 0:
		return
	if not talk_sound:
		return
	player.stream = talk_sound
	player.pitch_scale = randf_range(0.8, 1.2)
	player.play()


func _on_interacted(_by: RapierArea2D) -> void:
	if not dialogue_resource:
		return
	_movement = get_component(MovementComponent) as MovementComponent
	if _movement:
		_movement.is_interacting = true
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start, [self])


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	if _movement:
		_movement.is_interacting = false
