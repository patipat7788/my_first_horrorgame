
extends Node3D

var torch_light: OmniLight3D
var base_energy: float
var target_energy: float
var timer: float = 0.0

func _ready() -> void:
	torch_light = find_child("OmniLight3D", true, false) as OmniLight3D

	if torch_light == null:
		push_warning("ไม่พบ OmniLight3D ในคบเพลิง")
		return

	base_energy = torch_light.light_energy
	target_energy = base_energy

func _process(delta: float) -> void:
	if torch_light == null:
		return

	timer -= delta

	if timer <= 0.0:
		target_energy = base_energy * randf_range(0.8, 1.2)
		timer = randf_range(0.08, 0.2)

	torch_light.light_energy = lerpf(
		torch_light.light_energy,
		target_energy,
		1.0 - exp(-8.0 * delta)
	)
