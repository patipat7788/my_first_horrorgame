
extends CharacterBody3D

@export var speed: float = 2.0
@export var rotation_speed: float = 5.0

@export var patrol_radius: float = 8.0
@export var min_distance: float = 3.0
@export var wait_time: float = 2.0

@onready var enemy: Node3D = $".."
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer

var isHunt = false
var has_target = false
var is_waiting = false


func _ready():

	randomize()

	agent.path_desired_distance = 0.5
	agent.target_desired_distance = 0.5

	await get_tree().physics_frame

	move_to_random_point()


func _physics_process(delta):

	if isHunt:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	if not has_target:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	if agent.is_navigation_finished():

		velocity.x = 0
		velocity.z = 0

		move_and_slide()

		has_target = false

		if not is_waiting:
			wait_and_move()

		return

	# ตำแหน่งถัดไป
	var next_position = agent.get_next_path_position()

	# คำนวณทิศทางเฉพาะแกน X และ Z
	var direction = Vector3(
		next_position.x - global_position.x,
		0,
		next_position.z - global_position.z
	).normalized()

	# เคลื่อนที่
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# หมุนตามทิศทาง
	if direction.length() > 0.01:

		var target_rotation = atan2(
			-direction.x,
			-direction.z
		)

		enemy.rotation.y = lerp_angle(
			enemy.rotation.y,
			target_rotation,
			rotation_speed * delta
		)

	# Animation
	animation_player.play("WalkAxeDown")

	move_and_slide()


func move_to_random_point():

	var navigation_map = agent.get_navigation_map()

	if not navigation_map.is_valid():
		return

	var found_position = false

	for i in range(15):

		# สุ่มตำแหน่งรอบ Enemy
		var random_offset = Vector3(
			randf_range(-patrol_radius, patrol_radius),
			0,
			randf_range(-patrol_radius, patrol_radius)
		)

		var candidate = global_position + random_offset

		# หาตำแหน่งที่ใกล้ที่สุดบน NavigationMesh
		var random_position = NavigationServer3D.map_get_closest_point(
			navigation_map,
			candidate
		)

		# ตรวจสอบระยะห่างจากตัว Enemy
		var distance = global_position.distance_to(random_position)

		if distance < min_distance:
			continue

		# ตรวจสอบว่าจุดที่สุ่มไม่ห่างจาก NavigationMesh มากเกินไป
		if candidate.distance_to(random_position) > 1.5:
			continue

		# กำหนดเป้าหมาย
		agent.target_position = random_position

		found_position = true
		break

	has_target = found_position


func wait_and_move():

	is_waiting = true

	await get_tree().create_timer(wait_time).timeout

	is_waiting = false

	if not isHunt:
		move_to_random_point()
