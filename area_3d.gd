extends Area3D

@export var event_ui: Control
@export var event_text: Label

@export_multiline var event_message: String = \
"มีบางอย่างผิดปกติ..."
@export var enemy_animation: AnimationPlayer
@export var run_animation_name: String = "SprintAxeUp"
@export var player: CharacterBody3D
@export var enemy: Node3D
@export var start_point: Marker3D
@export var end_point: Marker3D
@export var look_target: Marker3D

var has_triggered: bool = false


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return

	if has_triggered:
		return

	has_triggered = true

	event_text.text = event_message
	event_ui.show()

	play_scare_event()


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return

	event_text.text = ""
	event_ui.hide()


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
	var tween := create_tween()
	tween.tween_property(
		enemy,
		"global_position",
		end_point.global_position,
		4.0
	)

	# รอจนศัตรูถึงจุดปลายทาง
	await tween.finished

	# หยุด Animation และซ่อนศัตรู
	if enemy_animation != null:
		enemy_animation.stop()

	enemy.visible = false
