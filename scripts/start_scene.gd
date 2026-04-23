extends Node2D

signal loadNewArea(current_scene, exit)
@onready var exit_area: Area2D = $exit_area
@export var exit_door: String = "main"


func _on_start_button_pressed() -> void:
	loadNewArea.emit(get_tree().current_scene, "main")



func _on_quit_button_pressed() -> void:
	get_tree().quit()
