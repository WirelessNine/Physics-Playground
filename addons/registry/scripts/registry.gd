class_name Registry
extends Object
##Singleton for loading and storing collections of resources from the file system.

const EXTENSIONS: PackedStringArray = ["tres", "res"]

static var _collections: Dictionary[String, Collection]


##Creates a new [Registry.Collection] with [param name] and [param type], from [param path].
static func create_collection(name: String, type: StringName, path: String) -> Collection:
	if not DirAccess.dir_exists_absolute(path):
		push_error("Path: ", path, " doesn't exist")
		return null

	if name in _collections:
		push_error(name, " already exists.")
		return null

	var array: Array

	_load_resources_into(array, type, path)

	var collection := Collection.new(array, name, path, type)

	_collections[name] = collection

	return collection


##Clears and reloads the resources in the [param collection].
static func refresh_collection(collection: Collection) -> void:
	collection.items.clear()

	_load_resources_into(collection.items, collection.type, collection.path)


##Returns the [Registry.Collection] with the matching [param name].
static func get_collection(name: String) -> Collection:
	if not name in _collections:
		push_error(name, " doesn't exists.")
		return null

	return _collections[name]


##Returns [code]true[/code] if a collection with the matching [param name] exists.
func has_collection(name: String) -> bool:
	return name in _collections


##Removes the [param collection] from the registry.
static func remove_collection(collection: Collection) -> void:
	_collections.erase(collection.name)


static func _load_resources_into(array: Array, type: StringName, path: String) -> void:
	var dir_access := DirAccess.open(path)

	if dir_access == null:
		push_error("Failed to open directory: ", path, ". Error: ", DirAccess.get_open_error())
		return

	dir_access.list_dir_begin()
	var file_name: String = dir_access.get_next()

	while not file_name.is_empty():
		if file_name.begins_with("."):
			file_name = dir_access.get_next()
			continue

		var full_path: String = path.path_join(file_name)

		if dir_access.current_is_dir():
			_load_resources_into(array, type, full_path)

		elif file_name.get_extension() in EXTENSIONS:
			var resource := load(full_path)

			if resource and _matches_class(resource, type):
				print(resource)
				array.append(resource)

		file_name = dir_access.get_next()


static func _matches_class(resource: Resource, type: StringName) -> bool:
	if type.is_empty():
		return true

	var script: Script = resource.get_script()
	return script and script.get_global_name() == type


##Container of resources.
class Collection:
	##[Array] of items stored in the collection.
	var items: Array
	##The collection's name.
	var name: String
	##The path where the collection's items are stored.
	var path: String
	##The type of the items stored.
	var type: StringName


	func _init(p_items: Array, p_name: String, p_path: String, p_type: StringName) -> void:
		items.assign(p_items)

		name = p_name
		path = p_path
		type = p_type


	##Returns the item whose file name matches [param item_name], if it exists.
	func get_item_name(item_name: String) -> Resource:
		for x: Resource in items:
			if x == null:
				continue

			if x.resource_path.get_file().get_basename() == item_name:
				return x

		return null


	##Returns [code]true[/code] if an item whose file name matches [param item_name] exists.
	func has_item(item_name: String) -> bool:
		return not get_item_name(item_name) == null
