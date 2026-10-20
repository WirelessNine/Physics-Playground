@abstract
class_name Utils
extends Object
##Singleton for functions and variables that have no clear home.


static func load_resources_recursive(path: String, resource_class: StringName = &"") -> Array:
	var dir_access: DirAccess = DirAccess.open(path)
	var array: Array = []

	_load_resources_recursive(dir_access, path, array, resource_class)

	return array


static func _load_resources_recursive(
	dir_access: DirAccess,
	path: String,
	array: Array,
	resource_class: StringName,
) -> void:
	for x: String in dir_access.get_files():
		if x.ends_with(".tres") or x.ends_with(".res"):
			var full_path: String = path.path_join(x)
			var resource: Resource = load(full_path)

			if (
				not resource_class.is_empty()
				and not resource.get_script().get_global_name() == resource_class
			):
				continue

			array.append(resource)

	for x: String in dir_access.get_directories():
		var next_path: String = path.path_join(x)
		var next_dir_access: DirAccess = DirAccess.open(next_path)
		_load_resources_recursive(next_dir_access, next_path, array, resource_class)
