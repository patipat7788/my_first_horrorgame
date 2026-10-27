
extends Node3D

var is_open := false
var is_moving := false
var is_unlcok = false
@export var open_angle: float = 90.0
@export var rotate_time: float = 0.4

func get_interaction_text() -> String:
	if !is_unlcok:
		return "ประตูล๊อค"
	if is_open:
		return "[E] ปิดประตู"
	return "[E] เปิดประตู"

func interact() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if is_moving:
		return

	if player.has_key and player.model_key.visible:
		player.model_key.visible = false
		is_unlcok = true
		Inventory.remove_item("กุญแจ")
	if !is_unlcok:
		print("ประตูล๊อค")
		return
	is_moving = true
	is_open = not is_open

	var target_angle = deg_to_rad(
		open_angle if is_open else 0.0
	)

	var tween = create_tween()
	tween.tween_property(
		self,
		"rotation:y",
		target_angle,
		rotate_time
	)

	tween.finished.connect(func():
		is_moving = false
	)
