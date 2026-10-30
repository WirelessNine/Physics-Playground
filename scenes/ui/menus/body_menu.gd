extends Menu

const BODY_SLOT: PackedScene = preload("uid://bregex5prhaps")
const BODY_ITEMS_FOLDER_PATH: String = "res://resources/items/bodies/"

@onready var bodies_scroll_v_box: VBoxContainer = %BodiesScrollFlow
@onready var clear_button: Button = %Clear
@onready var tooltip: Label = $Tooltip

var body_slot_pool: ScenePool
var body_items_collection: Registry.Collection


func _ready() -> void:
	tooltip.hide()

	body_slot_pool = ScenePool.new(
		ScenePool.AccessMode.BATCHED,
		BODY_SLOT,
		bodies_scroll_v_box,
		-1,
		10,
		_action_method,
	)

	body_items_collection = Registry.create_collection(
		"body_items",
		&"BodyItem",
		BODY_ITEMS_FOLDER_PATH,
	)

	body_slot_pool.update_scenes(body_items_collection.items, update_slot)


func update_slot(slot: Button, item: BodyItem) -> void:
	slot.update(item)


func _action_method(action: ScenePool.ActionMode, scene: Control) -> void:
	match action:
		ScenePool.ActionMode.CREATED:
			scene.selected.connect(_on_slot_selected)
			scene.mouse_entered.connect(_on_slot_mouse_entered.bind(scene))
			scene.mouse_exited.connect(_on_slot_mouse_exited)

			scene.hide()
		ScenePool.ActionMode.REQUESTED:
			scene.show()
		ScenePool.ActionMode.RETURNED:
			scene.hide()


func _on_slot_selected(body_item: BodyItem) -> void:
	Events.body_item_selected.emit(body_item)


func _on_slot_mouse_entered(slot: Button) -> void:
	tooltip.reparent(slot)
	tooltip.show()
	tooltip.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	tooltip.text = slot.body_item.name


func _on_slot_mouse_exited() -> void:
	tooltip.hide()


func _on_clear_pressed() -> void:
	for x: AdvancedBody2D in Simulation.bodies:
		x.queue_free()
