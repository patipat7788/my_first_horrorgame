
extends Area3D

func get_interaction_text() -> String:
	return "กุญแจ"

func interact() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
			return

	Inventory.add_item("กุญแจ")
	player.obtain_key()
	queue_free()
