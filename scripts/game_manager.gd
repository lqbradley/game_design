extends Node

var exits
var spawn_points
var current_scene

@onready var player_scene: PackedScene = preload("res://scenes/player3.tscn")

var level1_tank1: PackedScene = preload("res://scenes/levels/level1_tank1.tscn")
var level1_sewer: PackedScene = preload("res://scenes/levels/level1_sewer.tscn")
var level1_boat: PackedScene = preload("res://scenes/levels/level_1_boat.tscn")
func _ready() -> void:
	_setup_level()


func _setup_level() -> void:
	exits = get_tree().get_nodes_in_group("exit")
	for exit in exits:
		if not exit.loadNewArea.is_connected(_on_exit_load_new_area):
			exit.loadNewArea.connect(_on_exit_load_new_area)
	_spawn_player()

func _on_exit_load_new_area(current_scene, exit_door) -> void:
	call_deferred("_switch_level", current_scene)

func _switch_level(current_scene) -> void:
	var next_level := _get_new_level(current_scene)

	if next_level == "level1_tank1":
		get_tree().change_scene_to_packed(level1_tank1)
	elif next_level == "level1_sewer":
		get_tree().change_scene_to_packed(level1_sewer)
	elif next_level == "level1_boat":
		get_tree().change_scene_to_packed(level1_boat)

	await get_tree().process_frame
	await get_tree().process_frame

	var scene := get_tree().current_scene
	if scene == null:
		return
		
	_setup_level()

func _spawn_player() -> void:
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	if spawn_points.is_empty():
		return

	var _player = player_scene.instantiate() as CharacterBody2D
	get_tree().current_scene.add_child(_player)
	_player.global_position = spawn_points[0].global_position

	var camera := Camera2D.new()
	_player.add_child(camera)
	camera.zoom = Vector2(3.0, 3.0)
	
	


func _get_new_level(current_level) -> String:
	if current_level.name == "level1_tank1":
		return "level1_sewer"
	elif current_level.name == "level1_sewer":
		return "level1_boat"
	else:
		return "level1_tank1"
