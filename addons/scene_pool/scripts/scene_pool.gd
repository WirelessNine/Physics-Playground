@icon("uid://duy0ckgvdiu83")
class_name ScenePool
extends RefCounted
##Container for a pool of scenes.

##Defines how the pool is accessed and managed.
enum AccessMode {
	##Nodes are taken and returned from the [member pool] individually, when needed.
	DYNAMIC,
	##Nodes are never taken from the [member pool], instead, they are updated in order, the used ones are enabled (requested), and the unused ones are disabled (returned).
	BATCHED,
}

##Defines modes for a scene.
enum ActionMode {
	CREATED,
	REQUESTED,
	RETURNED,
}

##The pool access mode.
var access_mode: AccessMode = AccessMode.DYNAMIC
##The packed scene instantiated for in the pool.
var packed_scene: PackedScene
##The parent node of all scenes created.
var parent: Node

##[Callable] called for various actions on a scene.
var action_method: Callable

##The max number of scenes that can exist in the pool.
var max_scenes: int = -1

##[Array] of all scenes pooled.
var pool: Array[Node]

##[Dictionary] of all active scenes from the pool.
var _active: Dictionary[Node, int]

var _flip: bool = false


func _init(
	p_access_mode: AccessMode,
	p_packed_scene: PackedScene,
	p_parent: Node,
	p_max_scenes: int = -1,
	p_start_scenes: int = 0,
	p_action_method: Callable = _default_action_method,
) -> void:
	access_mode = p_access_mode
	packed_scene = p_packed_scene
	parent = p_parent
	max_scenes = p_max_scenes

	action_method = p_action_method

	create_scene(p_start_scenes)


func _to_string() -> String:
	return "ScenePool of %s" % packed_scene


##Instatiates scenes based on the amount of [param instances].
func create_scene(instances: int) -> void:
	if instances <= 0:
		return

	var pool_size: int = pool.size()
	var max_instances: int

	if max_scenes <= 0:
		max_instances = instances
	else:
		max_instances = min(instances, max_scenes - pool_size)

	if max_instances == 1:
		pool.append(_instantiate_scene())
	else:
		pool.resize(pool_size + max_instances)

		for x: int in range(pool_size, pool_size + max_instances):
			pool[x] = _instantiate_scene()


##Requests a single scene from the [member pool] and returns it if possible. Only for Dynamic access mode.
func request_scene() -> Node:
	if not access_mode == AccessMode.DYNAMIC:
		push_error("access_mode is not DYNAMIC!")
		return null

	var scene: Node = null
	var scene_index: int = -1

	if is_pool_exhausted():
		if is_pool_full():
			push_warning(self, ": Pool is exhausted and full!")
			return scene

		create_scene(1)

		scene_index = pool.size() - 1
		scene = pool[scene_index]
	else:
		var pool_range: Array[int]
		var pool_size: int = pool.size()

		if not _flip:
			pool_range.assign(range(0, pool_size))
		else:
			pool_range.assign(range(pool_size - 1, -1, -1))

		_flip = not _flip

		for x: int in pool_range:
			var item: Node = pool[x]

			if item == null or item in _active:
				continue

			scene = item
			scene_index = x

			break

	if scene == null:
		push_error(self, ": Failed to find requested scene.")

	pool[scene_index] = null
	_active[scene] = scene_index

	_call_action_method(ActionMode.REQUESTED, scene)

	return scene


##Returns the [param scene] back to the [member pool]. Only for Dynamic access mode.
func return_scene(scene: Node) -> void:
	if scene == null:
		return

	if not access_mode == AccessMode.DYNAMIC:
		push_error("access_mode is not DYNAMIC!")
		return

	if not scene in _active:
		push_error(scene, " is not active or part of the pool!")
		return

	var index: int = _active[scene]

	pool[index] = scene
	_active.erase(scene)

	_call_action_method(ActionMode.RETURNED, scene)


##Calls the [param method] for each scene from the pool, with items from the [param array].[br]
##The first parameter should be the scene/node, and the second one the item from the [param array].
func update_scenes(array: Array, method: Callable) -> void:
	if not access_mode == AccessMode.BATCHED:
		push_error("access_mode is not BATCHED!")
		return

	var array_size: int = array.size()
	var pool_size: int = pool.size()

	if array_size > pool_size:
		create_scene(array_size - pool_size)
	elif array_size < pool_size:
		for x: int in range(array_size, pool_size):
			_call_action_method(ActionMode.RETURNED, pool[x])

	for x: int in array_size:
		var item: Variant = array[x]
		var scene: Node = pool[x]

		_call_action_method(ActionMode.REQUESTED, scene)

		method.call(scene, item)


##Returns [code]true[/code] if no scenes can be instantiated anymore.
func is_pool_full() -> bool:
	if max_scenes <= 0:
		return false
	else:
		return pool.size() >= max_scenes


##Returns [code]true[/code] if all scenes are active.
func is_pool_exhausted() -> bool:
	return pool.size() == _active.size()


func _default_action_method(action_mode: ActionMode, scene: Node) -> void:
	match action_mode:
		ActionMode.CREATED:
			if scene is CanvasItem:
				scene.hide()
		ActionMode.REQUESTED:
			if scene is CanvasItem:
				scene.show()
		ActionMode.RETURNED:
			if scene is CanvasItem:
				scene.hide()


func _instantiate_scene() -> Node:
	var scene: Node = packed_scene.instantiate()
	parent.add_child(scene)

	_call_action_method(ActionMode.CREATED, scene)

	return scene


func _call_action_method(mode: ActionMode, scene: Node) -> void:
	action_method.call(mode, scene)
