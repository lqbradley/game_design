extends AnimatedSprite2D

@onready var exit_area: Area2D = $exit_area

signal loadNewArea(current_scene, exit)
signal playerArrived
signal reactivateDoor

var currentScene

var is_enough_collected: bool = false

# Called when the no de enters the scene tree for the first time.
func _ready() -> void:
	currentScene = get_tree().current_scene # get the name
	currentScene.enoughCollected.connect(_on_enough_collected)

func _on_exit_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D && is_enough_collected:
		loadNewArea.emit(currentScene, "main")
	else:
		playerArrived.emit()

func _on_exit_area_body_exited(body: Node2D) -> void:
	reactivateDoor.emit()



func _on_enough_collected():
	is_enough_collected = true
