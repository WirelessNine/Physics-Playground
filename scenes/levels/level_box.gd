extends Node

var body_item: BodyItem


func _ready() -> void:
	Events.body_item_selected.connect(
		func(b: BodyItem) -> void:
			body_item = b,
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"spawn_object"):
		if body_item == null:
			return

		var object: AdvancedBody2D = body_item.scene.instantiate()
		add_child(object)
		object.position = object.get_global_mouse_position()
		object.reset_physics_interpolation()

		Simulation.bodies.append(object)
