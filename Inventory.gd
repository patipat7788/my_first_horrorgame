extends Node

signal inventory_changed
signal selection_changed

var items: Array[String] = []
var selected_item: String = ""

func add_item(item_name: String) -> void:
	if items.has(item_name):
		return

	items.append(item_name)
	inventory_changed.emit()

func has_item(item_name: String) -> bool:
	return items.has(item_name)

func select_item(item_name: String) -> void:
	if not items.has(item_name):
		return

	selected_item = item_name
	selection_changed.emit()
func remove_item(item_name: String) -> void:
	if not items.has(item_name):
		return

	items.erase(item_name)

	if selected_item == item_name:
		selected_item = ""
		selection_changed.emit()

	inventory_changed.emit()
