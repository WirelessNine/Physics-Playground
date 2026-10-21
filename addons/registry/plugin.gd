@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"Registry",
		"Object",
		preload("uid://c7v7v73semuj7"),
		preload("uid://bgfauwau1k3ba"),
	)


func _exit_tree() -> void:
	remove_custom_type("Registry")
