
extends Node

@export var interact_ray: RayCast3D
@export var prompt_label: Label

var current_target: Node = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if current_target != null:
			if current_target.has_method("interact"):
				current_target.interact()

func _process(_delta: float) -> void:
	current_target = null
	prompt_label.hide()

	if not interact_ray.is_colliding():
		return

	var target = interact_ray.get_collider()

	while target != null:
		if target.has_method("get_interaction_text"):
			current_target = target
			prompt_label.text = target.get_interaction_text()
			prompt_label.show()
			return

		target = target.get_parent()
