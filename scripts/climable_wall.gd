extends AnimatableBody2D

@onready var player_float: CharacterBody2D = $"../player_float"

func _on_climb_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.is_climbing = true


func _on_climb_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.is_climbing = false
