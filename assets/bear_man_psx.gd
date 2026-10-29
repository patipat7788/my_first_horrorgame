extends Node3D

@export var player: Node3D

func _process(_delta: float) -> void:
	if player == null:
		return

	var target_position = player.global_position
	target_position.y = global_position.y

	look_at(target_position, Vector3.UP)
