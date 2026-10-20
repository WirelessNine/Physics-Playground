extends Button

signal selected(body_item: BodyItem)

var body_item: BodyItem


func _init() -> void:
	toggled.connect(_on_toggled)

	toggle_mode = true
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button_group = load("uid://c0xjeef5n5iem")


func update(new_body_item: BodyItem) -> void:
	if new_body_item == null:
		icon = null
		body_item = null
		return

	icon = new_body_item.icon
	body_item = new_body_item


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on and not body_item == null:
		selected.emit(body_item)
