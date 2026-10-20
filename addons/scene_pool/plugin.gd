@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"ScenePool",
		"RefCounted",
		preload("uid://cad1ntth24cpl"),
		preload("uid://duy0ckgvdiu83"),
	)


func _exit_tree() -> void:
	remove_custom_type("ScenePool")
