extends Node2D

#Drag constants
const DRAG_STIFFNESS: float = 800.0
const DRAG_DAMPING: float = 40.0

#Drag variables
var dragged_body_rid: RID
var drag_point: Vector2
var drag_query: PhysicsPointQueryParameters2D

var global_mouse: Vector2
var space_state: PhysicsDirectSpaceState2D


func _ready() -> void:
	drag_query = PhysicsPointQueryParameters2D.new()


func _physics_process(_delta: float) -> void:
	global_mouse = get_global_mouse_position()
	space_state = get_world_2d().direct_space_state

	_drag_input()
	_drag_process()


##Detects mouse clicks and checks if there are any bodies.
func _drag_input() -> void:
	if not Input.is_action_just_pressed(&"left_button"):
		if Input.is_action_just_released(&"left_button"):
			dragged_body_rid = RID()
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


func _is_rid_rigid(rid: RID) -> bool:
	return PhysicsServer2D.body_get_mode(rid) == PhysicsServer2D.BODY_MODE_RIGID
