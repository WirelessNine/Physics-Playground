extends Menu

const BODY_SLOT: PackedScene = preload("uid://bregex5prhaps")
const BODY_ITEMS_FOLDER_PATH: String = "res://resources/items/bodies/"

@onready var bodies_scroll_v_box: FlowContainer = %BodiesScrollFlow

@onready var environment_button: Button = %Environment
@onready var material_button: Button = %Material
@onready var clear_button: Button = %Clear

var body_slot_pool: ScenePool

var _body_items: Array[BodyItem]


func _ready() -> void:
	body_slot_pool = ScenePool.new(
		ScenePool.AccessMode.BATCHED,
		BODY_SLOT,
		bodies_scroll_v_box,
		-1,
		10,
		_action_method,
	)

	_load_body_items()

	body_slot_pool.update_scenes(_body_items, update_slot)


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


func _load_body_items() -> void:
	_body_items = []
	_body_items.assign(Utils.load_resources_recursive(BODY_ITEMS_FOLDER_PATH, &"BodyItem"))


func _on_slot_selected(body_item: BodyItem) -> void:
	Events.body_item_selected.emit(body_item)
