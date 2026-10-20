@icon("uid://bihio0mlqs1sj")
class_name BodyItem
extends Resource
##Stores details about a physics body that can be spawned.

##The body's icon, shown in the UI.
@export var icon: Texture2D
##The body's name, shown in the UI.
@export_placeholder("Name") var name: String
##The body's description, shown in the UI.
@export_multiline var description: String
##The [PackedScene] that contains the body.
@export var scene: PackedScene
