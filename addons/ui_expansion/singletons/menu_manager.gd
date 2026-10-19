extends Node

var background: Control
var _active_menus: Dictionary[String, Menu]
var _stack: Array[Menu]


func _unhandled_key_input(event: InputEvent) -> void:
	if _stack.is_empty():
		return

	if not (event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE):
		return

	var menu: Menu = _stack.back()
	menu.close()


##Adds a new [Menu].
func add_menu(menu: Menu) -> void:
	_active_menus[menu.name.to_snake_case()] = menu


##Removes a [Menu].
func remove_menu(menu: Menu) -> void:
	_active_menus.erase(menu.name.to_snake_case())

	remove_from_stack(menu)


##Returns the [Menu] whose [param menu_name] matches.
func get_menu(menu_name: String) -> Menu:
	if not menu_name in _active_menus:
		push_error(menu_name, " does not exist!")
		return

	return _active_menus[menu_name]


##Opens the [Menu] whose [param menu_name] matches.
func open_menu(menu_name: String) -> void:
	if not menu_name in _active_menus:
		push_error(menu_name, " does not exist!")
		return

	_active_menus[menu_name].open()


##Closes the [Menu] whose [param menu_name] matches.
func close_menu(menu_name: String) -> void:
	if not menu_name in _active_menus:
		push_error(menu_name, " does not exist!")
		return

	_active_menus[menu_name].close()


##Adds [param menu] to the stack.
func add_to_stack(menu: Menu) -> void:
	_stack.append(menu)

	menu.z_index = _stack.size()
	move_background(menu)


##Removes [param menu] to the stack.
##If [param erase_only], the menu is only removed from the stack.
func remove_from_stack(menu: Menu) -> void:
	var menu_index: int = _stack.find(menu)
	var last_index: int = _stack.size() - 1

	_stack.erase(menu)
	menu.z_index = 0

	if not menu_index == last_index:
		return

	move_background(_stack.back() if not _stack.is_empty() else null)


##Returns [code]true[/code] if the menu stack is empty.
func is_stack_empty() -> bool:
	return _stack.is_empty()


##Sets [member background] to [param new_background].
func set_background(new_background: Control) -> void:
	background = new_background

	new_background.hide()
	new_background.z_index = -1


##Moves the [member background] behind [param menu].
##If no backgrond is defined, nothing happens.
func move_background(menu: Menu) -> void:
	if background == null:
		return

	if menu == null or not menu.move_background:
		background.hide()
		return

	background.z_index = menu.z_index
	background.show()
