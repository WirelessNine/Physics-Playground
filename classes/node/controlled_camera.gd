extends Camera2D

const DRAG_WEIGHT: float = 30.0
const ZOOM_INC: float = 0.25
const ZOOM_MIN: float = 0.1
const ZOOM_MAX: float = 2.0

var is_dragging: bool
var target_position: Vector2
var target_zoom: Vector2


func _ready() -> void:
	target_position = position
	target_zoom = zoom


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"camera_drag"):
		is_dragging = true
	elif event.is_action_released(&"camera_drag"):
		is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		target_position -= event.relative / zoom

	if event.is_action_pressed(&"camera_zoom_in") or event.is_action_pressed(&"camera_zoom_out"):
		var mouse_pos: Vector2 = get_global_mouse_position()

		var old_zoom: Vector2 = target_zoom

		if event.is_action_pressed(&"camera_zoom_in"):
			target_zoom *= (1.0 + ZOOM_INC)
		else:
			target_zoom /= (1.0 + ZOOM_INC)

		target_zoom.x = clamp(target_zoom.x, ZOOM_MIN, ZOOM_MAX)
		target_zoom.y = clamp(target_zoom.y, ZOOM_MIN, ZOOM_MAX)

		target_position = mouse_pos + (target_position - mouse_pos) * (old_zoom / target_zoom)


func _process(delta: float) -> void:
	position = position.lerp(target_position, delta * DRAG_WEIGHT)
	zoom = zoom.lerp(target_zoom, delta * DRAG_WEIGHT)
