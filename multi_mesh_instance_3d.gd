extends MultiMeshInstance3D

@export var area_size := 32.0

func _ready():
	var mm = multimesh

	for i in range(mm.instance_count):
		var x = randf_range(-area_size / 2, area_size / 2)
		var z = randf_range(-area_size / 2, area_size / 2)

		var transform = Transform3D()
		transform.origin = Vector3(x, 0, z)

		mm.set_instance_transform(i, transform)
