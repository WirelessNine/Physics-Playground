extends Node

const PLACEHOLDER: PackedScene = preload("uid://bkaa0hbhyn7ap")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"spawn_object"):
		var object: RapierRigidBody2D = PLACEHOLDER.instantiate()
		add_child(object)
		object.position = object.get_global_mouse_position()
