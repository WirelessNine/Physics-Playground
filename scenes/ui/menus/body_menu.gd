extends Menu

const BODY_SLOT: PackedScene = preload("uid://bregex5prhaps")
const BODY_ITEMS_FOLDER_PATH: String = "res://resources/items/bodies/"

@onready var bodies_scroll_v_box: FlowContainer = %BodiesScrollFlow

@onready var environment_button: Button = %Environment
@onready var material_button: Button = %Material
@onready var clear_button: Button = %Clear

var body_slot_pool: ScenePool
var body_items_collection: Registry.Collection


func _ready() -> void:
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


func _action_method(action: ScenePool.ActionMode, scene: CanvasItem) -> void:
	match action:
		ScenePool.ActionMode.CREATED:
			scene.selected.connect(_on_slot_selected)

			scene.hide()
		ScenePool.ActionMode.REQUESTED:
			scene.show()
		ScenePool.ActionMode.RETURNED:
			scene.hide()


func _on_slot_selected(body_item: BodyItem) -> void:
	Events.body_item_selected.emit(body_item)
