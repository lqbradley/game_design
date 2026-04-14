extends Sprite2D

signal loadNewArea(current_scene, exit)
@onready var exit_area: Area2D = $exit_area
@export var exit_door: String = "main"

var currentScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentScene = get_tree().current_scene # get the name

func _on_exit_area_body_entered(body: Node2D) -> void:
	# TODO: need animation of player slowing disappearing inside
	loadNewArea.emit(currentScene, exit_door)
