@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"Menu",
		"PanelContainer",
		preload("uid://rxwty6cd03ab"),
		preload("uid://lxuugoybnvfh"),
	)

	add_custom_type(
		"TweenPreset",
		"Resource",
		preload("uid://cdo6h5x4glwop"),
		preload("uid://dxaulw3y3ck13"),
	)

	add_custom_type(
		"TweenStep",
		"Resource",
		preload("uid://ddiy46s8pndwo"),
		preload("uid://cafpoflngjk4j"),
	)


func _exit_tree() -> void:
	remove_custom_type("Menu")

	remove_custom_type("TweenPreset")
	remove_custom_type("TweenStep")


func _enable_plugin() -> void:
	add_autoload_singleton("MenuManager", "res://addons/ui_expansion/singletons/menu_manager.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("MenuManager")
