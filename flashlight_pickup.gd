
extends Area3D

func get_interaction_text() -> String:
	return "ไฟ"

func interact() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
			return

	Inventory.add_item("ไฟฉาย")
	player.obtain_flashlight()
	queue_free()
