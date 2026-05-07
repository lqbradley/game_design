extends Node2D

signal loadNewArea(current_scene, exit)
@onready var exit_area: Area2D = $exit_area
@export var exit_door: String = "main"

var currentScene
const WAIT_TIMER_TIME: float = 15.0

# Called when the no de enters the scene tree for the first time.
func _ready() -> void:
	currentScene = get_tree().current_scene # get the name
	await get_tree().create_timer(WAIT_TIMER_TIME).timeout
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	
func _on_exit_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		loadNewArea.emit(currentScene, exit_door)
