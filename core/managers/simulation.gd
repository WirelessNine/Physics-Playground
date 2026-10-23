extends Node2D

const DRAG_STIFFNESS: float = 800.0
const DRAG_DAMPING: float = 40.0

var dragged_body: RID
var drag_grab_point := Vector2.ZERO
var drag_query := PhysicsPointQueryParameters2D.new()


func _ready() -> void:
	drag_query.collide_with_bodies = true


func _physics_process(_delta: float) -> void:
	_drag_input()
	_drag_process()


func _drag_input() -> void:
	if dragged_body.is_valid():
		if not Input.is_action_pressed(&"left_button"):
			dragged_body = RID()
		return

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	drag_query.position = get_global_mouse_position()

	var results: Array[Dictionary] = space_state.intersect_point(drag_query, 1)

	if not results.size() > 0:
		return

	dragged_body = results[0].rid
	var body_xform: Transform2D = PhysicsServer2D.body_get_state(
		dragged_body,
		PhysicsServer2D.BODY_STATE_TRANSFORM,
	)

	drag_grab_point = body_xform.affine_inverse() * get_global_mouse_position()
	PhysicsServer2D.body_set_state(dragged_body, PhysicsServer2D.BODY_STATE_CAN_SLEEP, true)


func _drag_process() -> void:
	if not dragged_body.is_valid():
		return

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragged_body = RID()
		return

	var state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(dragged_body)

	var r: Vector2 = drag_grab_point.rotated(state.transform.get_rotation())
	var current_grab_pos: Vector2 = state.transform.origin + r
	var error: Vector2 = get_global_mouse_position() - current_grab_pos

	var point_velocity: Vector2 = state.linear_velocity + Vector2(
		-state.angular_velocity * r.y,
		state.angular_velocity * r.x,
	)

	var body_mass: float = 1.0 / state.inverse_mass

	var stiffness: float = DRAG_STIFFNESS * body_mass
	var damping: float = DRAG_DAMPING * body_mass
	var force: Vector2 = (error * stiffness) - (point_velocity * damping)

	PhysicsServer2D.body_apply_force(dragged_body, force, r)
