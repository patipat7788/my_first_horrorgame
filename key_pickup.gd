
extends Area3D
@export var enemy_animation: AnimationPlayer
@export var run_animation_name: String = "SprintAxeUp"
var player
@export var enemy: Node3D
@export var start_point: Marker3D
@export var end_point: Marker3D
@export var look_target: Marker3D
func get_interaction_text() -> String:
	return "กุญแจ"

func interact() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
			return

	Inventory.add_item("กุญแจ")
	player.obtain_key()
	await play_scare_event()
	queue_free()
func play_scare_event() -> void:
	print("Player: ", player)
	print("Enemy: ", enemy)
	print("Start Point: ", start_point)
	print("End Point: ", end_point)
	print("Look Target: ", look_target)

	if enemy == null:
		push_error("Enemy ยังไม่ได้กำหนด")
		return

	if start_point == null:
		push_error("Start Point ยังไม่ได้กำหนด")
		return

	if end_point == null:
		push_error("End Point ยังไม่ได้กำหนด")
		return

	if player == null:
		push_error("Player ยังไม่ได้กำหนด")
		return

	if look_target == null:
		push_error("Look Target ยังไม่ได้กำหนด")
		return

	# วางศัตรูที่จุดเริ่มต้น
	enemy.global_position = start_point.global_position
	enemy.visible = true
	var direction := end_point.global_position - start_point.global_position
	direction.y = 0.0

	if direction.length_squared() > 0.001:
		enemy.look_at(
		enemy.global_position + direction,
		Vector3.UP
	)
	# เล่น Animation วิ่งวนซ้ำ
	if enemy_animation != null:
		enemy_animation.play(run_animation_name)
	
	# ให้ผู้เล่นหันไปมอง
	player.look_toward_event(look_target.global_position)
	
	# เคลื่อนศัตรูจาก Start ไป End ใช้เวลา 4 วินาที
	var tween := get_tree().create_tween()
	tween.tween_property(
	enemy,
	"global_position",
	end_point.global_position,
	1
)
	await tween.finished


	# หยุด Animation และซ่อนศัตรู
	if enemy_animation != null:
		enemy_animation.stop()

	enemy.visible = false
