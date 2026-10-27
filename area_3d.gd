
extends Area3D

@export var event_ui: Control
@export var event_text: Label

@export_multiline var event_message: String = \
"มีบางอย่างผิดปกติ..."

var has_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return

	if has_triggered:
		return

	has_triggered = true

	event_text.text = event_message
	event_ui.show()


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return

	if has_triggered :
		event_text.text=""
		event_ui.hide()
