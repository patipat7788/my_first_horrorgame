
extends Node3D
@export var event_ui: Control
@export var event_text: Label
@export_multiline var event_message: String = \
"ตัวเล็กจัง เด็กหรอ......"
func get_interaction_text() -> String:
	return "[E] Interact"

func interact() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player.is_in_group("Player"):
		return
	
	event_text.text = event_message
	event_ui.show()
	await get_tree().create_timer(2.0).timeout
	event_ui.hide()
