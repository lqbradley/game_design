extends AnimatableBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal brain_collected
var tween: Tween
var DISTANCE: Vector2 = Vector2(64,0)
var start_pos
func _ready():
	start_pos = self.global_position
	start_tween()

func start_tween():
	tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.bind_node(self)
	tween.set_loops().set_parallel(false)
	tween.tween_property(self, "position", start_pos - DISTANCE, 4.0 / 2)
	tween.tween_callback(Callable(sprite, "set_flip_h").bind(true))
	tween.tween_property(self, "position", start_pos, 4.0 / 2)
	tween.tween_callback(Callable(sprite, "set_flip_h").bind(false))

	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		brain_collected.emit()
		queue_free()
