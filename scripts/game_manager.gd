extends Node

var exits
var spawn_points
var current_scene

@onready var player_scene: PackedScene = preload("res://scenes/player3.tscn")
var minimap_scene: PackedScene = preload("res://scenes/objects/mini_map.tscn")

var level1_tank1: PackedScene = preload("res://scenes/levels/level1_tank1.tscn")
var level1_sewer: PackedScene = preload("res://scenes/levels/level1_sewer.tscn")
var level1_boat: PackedScene = preload("res://scenes/levels/level_1_boat.tscn")

@onready var shrimp_texture = load("res://assets/sprites/sprite/shrimp_marker.png")
@onready var goldfish_texture = load("res://assets/sprites/sprite/goldfish_marker.png")


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
	current_scene = scene
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
	
	_add_minimap(_player)
	
	


func _add_minimap(_player) -> void:		
	current_scene = get_tree().current_scene
	var _minimap = minimap_scene.instantiate()
	_minimap.name = "mini-map"
	_minimap.player_node = _player
	
	var _minimap_sewer = _minimap.find_child("mini_map_sewer", true, false)
	
	
	current_scene.add_child.call_deferred(_minimap, true)
	_assign_goal_object.call_deferred(get_tree().current_scene,_minimap)
	
	if _minimap_sewer:
		_minimap_sewer.player_node = _player
	
	
		
func _assign_goal_object(current_level, _minimap) -> void:
	if current_level.name == "level1_tank1":
		_minimap.goal_object = current_level.get_node("goldfish")
		_minimap.goal_marker.texture = goldfish_texture
	elif current_level.name == "level1_boat":
		_minimap.goal_marker.texture = shrimp_texture
		_minimap.goal_object = current_level.get_node("shrimp")

func _get_new_level(current_level) -> String:
	if current_level.name == "level1_tank1":
		return "level1_sewer"
	elif current_level.name == "level1_sewer":
		return "level1_boat"
	else:
		return "level1_tank1"
