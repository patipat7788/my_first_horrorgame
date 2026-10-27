
extends HBoxContainer

@onready var slots: Array[PanelContainer] = [
	$Slot1,
	$Slot2,
	$Slot3
]

@onready var labels: Array[Label] = [
	$Slot1/ItemLabel,
	$Slot2/ItemLabel,
	$Slot3/ItemLabel
]


func _ready() -> void:
	print("ตัวที่ติดสคริปต์: ", get_path())
	print("ลูกของ Hotbar: ", get_children())
	print("หา Slot1: ", get_node_or_null("Slot1"))
	Inventory.inventory_changed.connect(refresh_hotbar)
	Inventory.selection_changed.connect(refresh_hotbar)
	refresh_hotbar()


func refresh_hotbar() -> void:
	for i in range(slots.size()):
		if slots[i] == null:
			push_error("Slot %d หาไม่เจอ" % (i + 1))
			continue

		if labels[i] == null:
			push_error("ItemLabel ของ Slot %d หาไม่เจอ" % (i + 1))
			continue

		var style := StyleBoxFlat.new()

		var is_selected := (
		i < Inventory.items.size()
		and Inventory.items[i] == Inventory.selected_item
		)

# พื้นหลังโปร่งแสง
		style.bg_color = Color(0.08, 0.09, 0.10, 0.45)

# ขอบบาง ๆ
		style.border_color = (
		Color(0.84, 0.86, 0.85, 0.95)
		if is_selected
		else Color(0.50, 0.54, 0.55, 0.30)
			)

		style.set_border_width_all(1)

# มุมโค้งเล็กน้อย
		style.set_corner_radius_all(4)

		slots[i].add_theme_stylebox_override("panel", style)
		if i < Inventory.items.size():
			labels[i].text = str(i + 1) + "\n" + Inventory.items[i]
		else:
			labels[i].text = str(i + 1) + "\nว่าง"
