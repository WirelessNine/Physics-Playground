@icon("uid://lxuugoybnvfh")
class_name Menu
extends PanelContainer

##Emitted when the menu is opened.
signal opened
##Emitted when the menu is closed.
signal closed

@export_group("Animation")
##The tween preset that plays the animation.
@export var preset: TweenPreset
##If [code]true[/code], the state can be overriden while the animation is playing.
@export var can_override: bool = true

@export_group("")
##If [code]true[/code], the menu is added to the Menu stack.
@export var add_to_stack: bool = true
##If [code]true[/code], the background is moved to behind the menu when opened. [br]
##[note]: A background node must me assigned in the MenuManager.
@export var move_background: bool = false
##If [code]true[/code], the menu is starts closed.
@export var start_closed: bool = false

var state: bool = false


func _init() -> void:
	_internal_init()


##Returns [code]true[/code] if the menu is open.
func is_open() -> bool:
	return state


##Opens the menu.
func open() -> void:
	if not _can_play() or state == true:
		return

	state = true

	_play_tween(false)

	if add_to_stack:
		MenuManager.add_to_stack(self)

	opened.emit()
	_opened()


##Closes the menu.
func close() -> void:
	if not _can_play() or state == false:
		return

	state = false

	_play_tween(true)

	if add_to_stack:
		MenuManager.remove_from_stack(self)

	closed.emit()
	_closed()


##Flips the menu between closed and open state.
func toggle() -> void:
	if state:
		close()
	else:
		open()


func _internal_init() -> void:
	ready.connect(_internal_ready)
	tree_entered.connect(_internal_enter_tree)
	tree_exited.connect(_internal_exit_tree)


func _internal_ready() -> void:
	_play_tween(start_closed, true)

	state = not start_closed


func _internal_enter_tree() -> void:
	MenuManager.add_menu(self)


func _internal_exit_tree() -> void:
	MenuManager.remove_menu(self)


func _can_play() -> bool:
	if not can_override and TweenPreset.is_playing(self):
		return false
	return true


func _play_tween(reverse: bool, instant: bool = false) -> void:
	if preset:
		if instant:
			preset.instant(self, reverse)
		else:
			preset.play(self, reverse)
	else:
		visible = not reverse


##Called when the menu is opened.
func _opened() -> void:
	pass


##Called when the menu is closed.
func _closed() -> void:
	pass
