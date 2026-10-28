extends CharacterBody3D

# ==========================================
# 1. ตั้งค่าความเร็วและการเคลื่อนที่
# ==========================================
var WALK_SPEED = 2.0     
const SPRINT_SPEED = 3.0   
const ACCELERATION = 4.0   
const DECELERATION = 6.0   
const JUMP_VELOCITY = 3.5
const MOUSE_SENSITIVITY = 0.002
var time_run = false
var has_flashlight := false
var flashlight_on := false
var has_key = false
# ==========================================
# 2. ตัวแปรระบบแกว่งหัวและเสียงเท้า
# ==========================================
const BOB_FREQ = 5.0 # ความถี่ก้าวเท้า (ปรับให้สับไวขึ้นตามที่จูนไว้)
const BOB_AMP = 0.04 # ความสูงที่กล้องโยก (ลดลงนิดหน่อยเพื่อไม่ให้เวียนหัว)
var t_bob = 0.0      
var can_play_step = true 
var mouse_state = false
# ==========================================
# 3. ดึงโหนดที่ต้องใช้ (References)
# ==========================================
@onready var camera = $Camera3D
@onready var initial_camera_pos = camera.position.y 
@onready var interact_ray = $Camera3D/RayCast3D 
@onready var flashlight: SpotLight3D = $Camera3D/SpotLight3D
@onready var model_flashlight: Node3D = $Camera3D/model_flashlight
@onready var model_key: Node3D = $Camera3D/model_key
# ระบบเคลื่อนไหวของไอเท็ม
@export var item_sway_amount: float = 0.04
@export var item_bob_amount: float = 0.015
@export var item_follow_speed: float = 5.0


var flashlight_start_pos: Vector3
var key_start_pos: Vector3

var flashlight_start_rot: Vector3
var key_start_rot: Vector3

var mouse_delta := Vector2.ZERO




# ดึงโหนดเสียง (ถ้าเปลี่ยนชื่อโหนดใน Scene อย่าลืมมาแก้ชื่อตรงนี้ให้ตรงกันนะครับ)
@onready var flashlight_sound: AudioStreamPlayer = $flashlight_sound
@onready var footstep_audio: AudioStreamPlayer = $footstep_audio

func select_hotbar_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= Inventory.items.size():
		return

	var item_name: String = Inventory.items[slot_index]

	# ถ้ากดช่องที่เลือกอยู่แล้ว ให้ยกเลิกการเลือก
	if Inventory.selected_item == item_name:
		Inventory.selected_item = ""
		Inventory.selection_changed.emit()

		model_flashlight.visible = false
		flashlight.visible = false
		flashlight_on = false
		model_key.visible = false
		return

	# ถ้าเป็นช่องใหม่ ให้เลือกไอเท็มนั้น
	Inventory.select_item(item_name)
	model_flashlight.visible = false
	model_key.visible = false
	flashlight.visible = false
	flashlight_on = false
	if item_name == "ไฟฉาย":
		model_flashlight.visible = true
	elif item_name == 'กุญแจ':
		model_key.visible = true
	else:
		model_flashlight.visible = false
		flashlight.visible = false
		flashlight_on = false
		model_key.visible = false

func obtain_key() -> void:
	has_key = true
func obtain_flashlight() -> void:
	has_flashlight = true
	flashlight.visible = false
	flashlight_on = false

func _input(event: InputEvent) -> void:
	# เปิด-ปิดไฟฉายได้เมื่อเก็บแล้วเท่านั้น
	if event.is_action_pressed("flashlight"):
		if has_flashlight and model_flashlight.visible:
			flashlight_on = !flashlight_on
			flashlight.visible = flashlight_on
			flashlight_sound.play()
	# กด E เพื่อโต้ตอบ
	if event.is_action_pressed("interact"):
		if not interact_ray.is_colliding():
			return

		var target = interact_ray.get_collider()
		var interactable = target

		while interactable != null and not interactable.has_method("interact"):
			interactable = interactable.get_parent()

		if interactable != null:
			interactable.interact()
	if event.is_action_pressed("slot_1"):
		select_hotbar_slot(0)
	if event.is_action_pressed("slot_2"):
		select_hotbar_slot(1)
	if event.is_action_pressed("slot_3"):
		select_hotbar_slot(2)

func _ready():
	# ซ่อนและล็อกเมาส์ไว้กลางจอ
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#ปิดไฟฉายตอนเริ่มเกม
	flashlight.visible = false
	model_flashlight.visible = false
	model_key.visible = false
	flashlight_start_pos = model_flashlight.position
	key_start_pos = model_key.position
	flashlight_start_rot = model_flashlight.rotation
	key_start_rot = model_key.rotation
func _unhandled_input(event):
	# ระบบหันหน้ามุมกล้อง
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		mouse_delta = event.relative
	if event.is_action_pressed("exit_ui"):
		mouse_state = ! mouse_state
		if mouse_state:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif !mouse_state :
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# ==========================================
# 4. ระบบส่งสัญญาณโต้ตอบ (Interaction)
# ==========================================
func _process(delta: float) -> void:
	var smooth := minf(delta * item_follow_speed, 1.0)

	# ความเร็วการเดินแนวราบ
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var moving := is_on_floor() and horizontal_speed > 0.1

	# แกว่งตามจังหวะเดินเดิมของคุณ
	var bob := 0.0
	if moving:
		bob = sin(t_bob * BOB_FREQ) * item_bob_amount

	# เอียงตามการหันเมาส์
	var sway_x := clampf(mouse_delta.y * 0.001, -0.04, 0.04)
	var sway_y := clampf(mouse_delta.x * 0.001, -0.04, 0.04)

	# ลดแรงจากเมาส์อย่างนุ่มนวล
	mouse_delta = mouse_delta.lerp(
		Vector2.ZERO, minf(delta * 8.0, 1.0)
	)

	# คำนวณเป้าหมายของไอเท็ม
	var flashlight_pos := flashlight_start_pos
	flashlight_pos.y += bob

	var key_pos := key_start_pos
	key_pos.y += bob

	var flashlight_rot := flashlight_start_rot
	flashlight_rot.x += sway_x
	flashlight_rot.y -= sway_y
	flashlight_rot.z += bob * 0.5

	var key_rot := key_start_rot
	key_rot.x += sway_x
	key_rot.y -= sway_y
	key_rot.z += bob * 0.5

	# ค่อย ๆ เคลื่อนเข้าหาเป้าหมาย
	model_flashlight.position = model_flashlight.position.lerp(
		flashlight_pos, smooth
	)
	model_flashlight.rotation = model_flashlight.rotation.lerp(
		flashlight_rot, smooth
	)

	model_key.position = model_key.position.lerp(
		key_pos, smooth
	)
	model_key.rotation = model_key.rotation.lerp(
		key_rot, smooth
	)

# ==========================================
# 5. ระบบคำนวณฟิสิกส์
# ==========================================
func _physics_process(delta):
	# แรงโน้มถ่วง
	if not is_on_floor():
		velocity += get_gravity() * delta

	# เช็ควิ่ง
	var current_speed = WALK_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = SPRINT_SPEED

	# รับค่าปุ่มเดินตาม Input Map ใหม่
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# เดินแบบมีน้ำหนัก
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = lerp(velocity.z, 0.0, DECELERATION * delta)

	# คำนวณแกว่งหัว
	t_bob += delta * velocity.length() * float(is_on_floor())
	var pos_y = sin(t_bob * BOB_FREQ) * BOB_AMP
	var pos_x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP 

	# ซิงก์เสียงฝีเท้า
	if velocity.length() > 0.5 and is_on_floor():
		if pos_y < -0.02 and can_play_step:
			# สุ่มเสียงและเพิ่ม Pitch ให้เสียงแหลม/เร็วขึ้นเล็กน้อยตอนวิ่ง
			footstep_audio.pitch_scale = randf_range(0.8, 1.1)
			if current_speed == SPRINT_SPEED:
				footstep_audio.pitch_scale += 0.2
				
			footstep_audio.play()
			can_play_step = false 
		elif pos_y > 0.02:
			can_play_step = true

	# คืนค่ากล้องตอนหยุดเดิน
	if velocity.length() < 0.1:
		pos_y = lerp(camera.position.y, initial_camera_pos, delta * 5.0) - initial_camera_pos
		pos_x = lerp(camera.position.x, 0.0, delta * 5.0)
		
	camera.position.y = initial_camera_pos + pos_y
	camera.position.x = pos_x

	move_and_slide()
