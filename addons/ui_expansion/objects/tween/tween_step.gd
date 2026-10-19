@tool
@icon("uid://cafpoflngjk4j")
class_name TweenStep
extends Resource

##Represents the most common properties for tweening.
enum TweenProperty {
	##[member Control.offset_transform_position] property.
	POSITION = 0,
	##[member Control.offset_transform_position_ratio] property.
	RATIO = 1,
	##[member Control.offset_transform_scale] property.
	SCALE = 2,
	##[member Control.offset_transform_rotation] property.
	ROTATION = 3,
	##[member Control.modulate] property.
	MODULATE = 4,
	##[member Control.modulate:a] property.
	ALPHA = 5,
	##Instance shader parameter of the [Control] node.
	SHADER = 6,
	##Other property of the [Control] node.
	OTHER = 7,
}

##The Variant types that can be used.
enum PropertyType {
	##Property of type [int].
	INT = TYPE_INT,
	##Property of type [float].
	FLOAT = TYPE_FLOAT,
	##Property of type [Color].
	COLOR = TYPE_COLOR,
	##Property of type [Vector2].
	VECTOR2 = TYPE_VECTOR2,
}

const SHADER_PREFIX = "instance_shader_parameters/%s"

const PROPERTY_RULES: Dictionary[TweenProperty, Dictionary] = {
	TweenProperty.POSITION: { "path": ^"offset_transform_position", "type": PropertyType.VECTOR2 },
	TweenProperty.RATIO: {
		"path": ^"offset_transform_position_ratio",
		"type": PropertyType.VECTOR2,
	},
	TweenProperty.SCALE: { "path": ^"offset_transform_scale", "type": PropertyType.VECTOR2 },
	TweenProperty.ROTATION: { "path": ^"offset_transform_rotation", "type": PropertyType.FLOAT },
	TweenProperty.ALPHA: { "path": ^"modulate:a", "type": PropertyType.FLOAT },
	TweenProperty.MODULATE: { "path": ^"modulate", "type": PropertyType.COLOR },
}

const TYPE_DEFAULTS: Dictionary[PropertyType, Variant] = {
	PropertyType.INT: 0,
	PropertyType.FLOAT: 0.0,
	PropertyType.COLOR: Color.WHITE,
	PropertyType.VECTOR2: Vector2.ZERO,
}

@export_group("Parameters")
##The transition for the step.
@export var transition: Tween.TransitionType = Tween.TRANS_LINEAR
##The easing for the step
@export var easing: Tween.EaseType = Tween.EASE_OUT
##The time it takes for the tweener to finish.
@export_range(0.0, 10.0, 0.01) var duration: float = 0.5:
	set(value):
		duration = value
		_update_resource_name()
##The delay before the step executes, pauses the entire execution.
@export_range(0.0, 10.0, 0.01) var delay: float = 0.0
##The delay before the tweener starts, does not pause execution.
@export_range(0.0, 10.0, 0.01) var tweener_delay: float = 0.0

@export_group("Property")
##The property to tween.
@export var tween_property: TweenProperty:
	set(value):
		tween_property = value

		if _is_tween_property_custom(value):
			start_value = type_convert(start_value, property_type)
			end_value = type_convert(end_value, property_type)
		else:
			var rules: Dictionary = PROPERTY_RULES[value]

			start_value = type_convert(start_value, rules.type)
			end_value = type_convert(end_value, rules.type)

		_update_resource_name()
		_set_color_values_default()
		notify_property_list_changed()
##The name of the custom property to tween.
@export var custom_property: String

@export_group("Value")
##If [code]true[/code], the end value will be used as a relative value instead. [br]
##[note]: Relative doesn't work in reverse, it instead tweens towards the start value.
@export var relative: bool = false
##If [code]true[/code], the node will snap to the start/end value before executing.
@export var snap: bool = false
##The type of the [member custom_property].
@export var property_type: PropertyType = PropertyType.INT:
	set(value):
		property_type = value

		start_value = type_convert(start_value, value)
		end_value = type_convert(end_value, value)

		_set_color_values_default()
		notify_property_list_changed()

##The value where the tween start. [br]
##[note]: It should represent the value when node is "off".
@export var start_value: Variant
##The value where the tween ends, It is the start value in [b]reverse[/b].
##[note]: It should represent the value when node is "on".
@export var end_value: Variant


func _init() -> void:
	if Engine.is_editor_hint():
		start_value = type_convert(start_value, _get_current_type())
		end_value = type_convert(end_value, _get_current_type())

		resource_name = TweenProperty.keys()[tween_property].capitalize()


func _validate_property(property: Dictionary) -> void:
	if (
		(property.name == &"property_type" or property.name == &"custom_property")
		and not _is_tween_property_custom(tween_property)
	):
		property.usage = 0

	if property.name == &"start_value" or property.name == &"end_value":
		property.type = _get_current_type()

		if tween_property == TweenProperty.SCALE:
			property.hint = PROPERTY_HINT_LINK


func _property_can_revert(property: StringName) -> bool:
	if property == &"start_value" or property == &"end_value":
		return true
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property == &"start_value" or property == &"end_value":
		return _get_current_type_revert()
	return null


##Executes the step using the [param tween] on the [param node].
func execute(tween: Tween, node: Control, reverse: bool) -> void:
	if delay > 0.0:
		tween.chain()
		tween.tween_interval(delay)
		tween.chain()

	var tween_start: Variant = start_value if not reverse else end_value
	var tween_end: Variant = end_value if not reverse else start_value

	if tween_property == TweenProperty.ROTATION:
		tween_start = deg_to_rad(tween_start)
		tween_end = deg_to_rad(tween_end)

	var property_path: NodePath = _get_property_path()

	if snap:
		tween.tween_callback(node.set_indexed.bind(property_path, tween_start))
		tween.chain()

	tween.set_trans(transition).set_ease(easing)
	var tweener: PropertyTweener = tween.tween_property(node, property_path, tween_end, duration)

	if tweener_delay > 0.0:
		tweener.set_delay(tweener_delay)

	if relative and not reverse:
		tweener.as_relative()


##Executes the step on the [param node] instantly.
func instant(node: Control, reverse: bool) -> void:
	var tween_end: Variant = end_value if not reverse else start_value
	var property_path: NodePath = _get_property_path()

	if tween_property == TweenProperty.ROTATION:
		tween_end = deg_to_rad(tween_end)

	node.set_indexed(property_path, tween_end)


##Returns the node path to the property.
func _get_property_path() -> NodePath:
	match tween_property:
		TweenProperty.OTHER:
			return NodePath(custom_property)
		TweenProperty.SHADER:
			return NodePath(SHADER_PREFIX % custom_property)
		_:
			var rules: Dictionary = PROPERTY_RULES[tween_property]

			return rules.path


##Returns [code]true[/code] if [param property] requires inputing the property name manually.
func _is_tween_property_custom(property: TweenProperty) -> bool:
	return property == TweenProperty.SHADER or property == TweenProperty.OTHER


##Returns the current property type to use now.
func _get_current_type() -> PropertyType:
	if _is_tween_property_custom(tween_property):
		return property_type
	else:
		var rules: Dictionary = PROPERTY_RULES[tween_property]

		return rules.type


##Returns the revert value of the current type.
func _get_current_type_revert() -> Variant:
	return TYPE_DEFAULTS[_get_current_type()]


##Sets the start and end value to white instead of black.
func _set_color_values_default() -> void:
	if tween_property == TweenProperty.MODULATE or property_type == PropertyType.COLOR:
		var color_default: Color = TYPE_DEFAULTS[PropertyType.COLOR]

		if not start_value is Color:
			start_value = color_default

		if not end_value is Color:
			end_value = color_default


func _update_resource_name() -> void:
	var property: String = TweenProperty.keys()[tween_property].capitalize()

	resource_name = "%s %.2fs" % [property, duration]
