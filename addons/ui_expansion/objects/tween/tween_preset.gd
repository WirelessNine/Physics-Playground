@icon("uid://dxaulw3y3ck13")
class_name TweenPreset
extends Resource

const TWEEN_META_NAME: StringName = &"tween"

##[Array] of [TweenStep]s executed in order to play an animation.
@export var steps: Array[TweenStep]
##If [code]true[/code], the node animated will be shown on start.
@export var show_on_start: bool = false
##If [code]true[/code], the node animated will be hidden on finish.
@export var hide_on_finish: bool = false


##Returns [code]true[/code] if the [param node] has a active tween.
static func is_playing(node: Control) -> bool:
	var tween: Tween = get_tween(node)

	return is_instance_valid(tween) and tween.is_running()


##Returns the [param node]'s [Tween].
static func get_tween(node: Control) -> Tween:
	if not node.has_meta(TWEEN_META_NAME):
		return null

	return node.get_meta(TWEEN_META_NAME)


##Sets the [param node]'s [Tween].
static func set_tween(node: Control, tween: Tween) -> void:
	node.set_meta(TWEEN_META_NAME, tween)


##Creates a new [Tween] for the [param node].
static func create_tween(node: Control) -> Tween:
	var tween: Tween = node.create_tween()

	if is_playing(node):
		get_tween(node).kill()

	set_tween(node, tween)

	return tween


##Plays the tween animation.
func play(node: Control, reverse: bool) -> void:
	if not node.offset_transform_enabled:
		node.offset_transform_enabled = true

	var tween: Tween = TweenPreset.create_tween(node)
	tween.set_parallel(true)

	if show_on_start and not reverse:
		node.show()

	for x: TweenStep in steps:
		x.execute(tween, node, reverse)

	if hide_on_finish and reverse:
		tween.chain()
		tween.tween_callback(node.hide)


func instant(node: Control, reverse: bool) -> void:
	if not node.offset_transform_enabled:
		node.offset_transform_enabled = true

	if show_on_start and not reverse:
		node.show()

	for x: TweenStep in steps:
		x.instant(node, reverse)

	if hide_on_finish and reverse:
		node.hide()
