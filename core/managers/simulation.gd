extends Node2D

#Drag constants
const DRAG_STIFFNESS: float = 800.0
const DRAG_DAMPING: float = 40.0
const ROTATION_SPEED: float = 180.0
const ROTATION_LERP_WEIGHT: float = 0.2

#Drag variables
var dragged_body_rid: RID
var drag_rotation_started: bool = false
var drag_rotation_offset: float = 0.0
var drag_point := Vector2.ZERO
var drag_query: PhysicsPointQueryParameters2D

var global_mouse: Vector2
var space_state: PhysicsDirectSpaceState2D


func _ready() -> void:
	drag_query = PhysicsPointQueryParameters2D.new()


func _physics_process(_delta: float) -> void:
	global_mouse = get_global_mouse_position()
	space_state = get_world_2d().direct_space_state

	_drag_input()
	_drag_rotation()
	_drag_process()


##Detects mouse clicks and checks if there are any bodies.
func _drag_input() -> void:
	if not Input.is_action_just_pressed(&"left_button"):
		if Input.is_action_just_released(&"left_button"):
			PhysicsServer2D.body_set_param(
				dragged_body_rid,
				PhysicsServer2D.BODY_PARAM_GRAVITY_SCALE,
				1.0,
			)
			dragged_body_rid = RID()
			drag_rotation_started = false
			drag_rotation_offset = 0.0
		return

	drag_query.position = global_mouse

	var results: Array[Dictionary] = space_state.intersect_point(drag_query, 1)

	if results.is_empty():
		return

	var rid: RID = results[0].rid

	if not _is_rid_rigid(rid):
		return

	var body_xform: Transform2D = PhysicsServer2D.body_get_state(
		rid,
		PhysicsServer2D.BODY_STATE_TRANSFORM,
	)

	dragged_body_rid = rid
	drag_point = body_xform.affine_inverse() * global_mouse


func _drag_rotation() -> void:
	if not dragged_body_rid.is_valid():
		return

	if (
		Input.is_action_just_pressed(&"rotate_left")
		or Input.is_action_just_pressed(&"rotate_right")
	):
		drag_rotation_started = true

		PhysicsServer2D.body_set_param(
			dragged_body_rid,
			PhysicsServer2D.BODY_PARAM_GRAVITY_SCALE,
			0.0,
		)

	var state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(dragged_body_rid)

	var radians: float = deg_to_rad(ROTATION_SPEED)

	if Input.is_action_pressed(&"rotate_left"):
		state.angular_velocity = lerpf(state.angular_velocity, -radians, ROTATION_LERP_WEIGHT)
	elif Input.is_action_pressed(&"rotate_right"):
		state.angular_velocity = lerpf(state.angular_velocity, radians, ROTATION_LERP_WEIGHT)


func _drag_process() -> void:
	if not dragged_body_rid.is_valid():
		return

	var state: PhysicsDirectBodyState2D = PhysicsServer2D.body_get_direct_state(dragged_body_rid)

	var r: Vector2 = drag_point.rotated(state.transform.get_rotation())
	var global_grab_pos: Vector2 = state.transform.origin + r
	var error: Vector2 = get_global_mouse_position() - global_grab_pos

	var point_velocity: Vector2 = state.linear_velocity + Vector2(
		-state.angular_velocity * r.y,
		state.angular_velocity * r.x,
	)

	var body_mass: float = 1.0 / state.inverse_mass

	var stiffness: float = DRAG_STIFFNESS * body_mass * Engine.time_scale
	var damping: float = DRAG_DAMPING * body_mass * Engine.time_scale
	var force: Vector2 = (error * stiffness) - (point_velocity * damping)

	PhysicsServer2D.body_apply_force(dragged_body_rid, force, r)

	if drag_rotation_started and not _is_rotation_input_pressed():
		state.angular_velocity = lerpf(state.angular_velocity, 0.0, ROTATION_LERP_WEIGHT)


func _is_rid_rigid(rid: RID) -> bool:
	return PhysicsServer2D.body_get_mode(rid) == PhysicsServer2D.BODY_MODE_RIGID


func _is_rotation_input_pressed() -> bool:
	return Input.is_action_pressed(&"rotate_left") or Input.is_action_pressed(&"rotate_right")
