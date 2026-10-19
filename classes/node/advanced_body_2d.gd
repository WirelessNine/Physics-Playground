class_name AdvancedBody2D
extends RapierRigidBody2D
##Extension of [RigidBody2D] to handle more complex things.

const DRAG_SPEED: float = 15.0

var is_dragged: bool = false
var grab_point: Vector2 = Vector2.ZERO


func _init() -> void:
	input_pickable = true
	can_sleep = false


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	):
		is_dragged = true
		grab_point = get_local_mouse_position()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_dragged and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_dragged = false

	if not is_dragged:
		return

	var r: Vector2 = grab_point.rotated(rotation)
	var current_grab_pos: Vector2 = global_position + r
	var error: Vector2 = get_global_mouse_position() - current_grab_pos

	var point_velocity: Vector2 = state.linear_velocity + Vector2(
		-state.angular_velocity * r.y,
		state.angular_velocity * r.x,
	)

	var stiffness: float = 800.0
	var damping: float = 40.0
	var force: Vector2 = (error * stiffness) - (point_velocity * damping)

	state.apply_force(force, r)
