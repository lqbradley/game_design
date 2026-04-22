extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_animation_player: AnimationPlayer = $CameraAnimationPlayer
const TEST_BUBBLE = preload("uid://br6gg2a60xh3l")
const TALKING_WITH_GOLDFISH = preload("uid://0tqsutlqwkbj")
const TALKING_WITH_SHRIMP = preload("uid://bdlfvfuu2xqia")
const TO_THE_KITCHEN = preload("uid://b6hsbkvktlakj")
const THE_KITCHEN = preload("uid://bpt71ijcpo2rw")


var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player/ColorRect.visible = true
	camera_animation_player.play("Cameras/fade_in")
	$Timer.start()
	await $Timer.timeout
	DialogueManager.show_dialogue_balloon(TALKING_WITH_GOLDFISH, "start")
	await DialogueManager.dialogue_ended
	forward_tween()
	camera_animation_player.play("Cameras/fade_out")
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/levels/level1_tank1.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func forward_tween():
	tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.bind_node(self)
	tween.set_loops(1).set_parallel(false)
	tween.tween_property($Player, "position", ($Player.position + Vector2(200, 0)), 3)
	
