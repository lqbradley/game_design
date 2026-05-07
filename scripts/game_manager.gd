extends Node

var exits
var spawn_points
var current_scene

@onready var player_scene: PackedScene = preload("res://scenes/player3.tscn")
var minimap_scene: PackedScene = preload("res://scenes/objects/mini_map.tscn")

var level1_tank1: PackedScene = preload("res://scenes/levels/level1_tank1.tscn")
var level1_sewer: PackedScene = preload("res://scenes/levels/level1_sewer.tscn")
var level1_boat: PackedScene = preload("res://scenes/levels/level_1_boat.tscn")
var end_screen: PackedScene = preload("res://scenes/levels/end_scene.tscn")

@onready var shrimp_texture = load("res://assets/sprites/sprite/shrimp_marker.png")
@onready var goldfish_texture = load("res://assets/sprites/sprite/goldfish_marker.png")

@onready var dialogue_balloon = load("res://scenes/objects/tutorial_balloon.tscn")
const LEVELS_LIST = [
	"start_scene",
	"level1_tank1",
	"level1_sewer",
	"level1_boat",
]

var current_level_index: int = 0
var player
func _ready() -> void:
	 
	_setup_level()
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_ended(resource) -> void:
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	

func _setup_level() -> void:
	exits = get_tree().get_nodes_in_group("exit")
	for exit in exits:
		if not exit.loadNewArea.is_connected(_on_exit_load_new_area):
			exit.loadNewArea.connect(_on_exit_load_new_area)
	player = _spawn_player()
	_give_instructions()
	


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
	elif next_level == "end_scene":
		get_tree().change_scene_to_packed(end_screen)		

	await get_tree().process_frame
	await get_tree().process_frame
	var scene := get_tree().current_scene
	current_scene = scene
	if scene == null:
		return
		
	_setup_level()

	
func _give_instructions() -> void:
	var dialogue_text: String 
	if get_tree().current_scene.name == "level1_tank1":
		dialogue_text = """~ start
Welcome to your first tank!
Press A or ← to move left
Press D or → to move right
Press the Space bar to jump
For this level, your goal is to get to the gold fish
You can see where you are relative to him by looking at the map on the bottom right of your screen
He tends to forget things though so be sure to collect enough memories for him
You need [b]SEVEN[/b] to go to the next level
Good luck!
=> END
"""
	elif get_tree().current_scene.name == "level1_sewer":
		dialogue_text = """~ start
Welcome to the sewer pipes!
Move around using WASD or Arrow keys
Your goal is to find the exit!
You can see where you are relative to the exit on the map at the bottom right
Good luck!
=> END
"""
	elif get_tree().current_scene.name == "level1_boat":
		dialogue_text = """~ start
Welcome to the final tank!
Same controls as the first tank
Additionally, press SHIFT to crouch and make yourself smaller
Your goal is to find the shrimp behind the rock!
He moves around a lot, so check out the map in the bottom right on where he is
Good luck!
=> END
"""
	elif get_tree().current_scene.name == "tutorial_level":
		dialogue_text = """~ start
=> END
"""
	if dialogue_text:
		var dialogue = DialogueManager.create_resource_from_text(dialogue_text)
		DialogueManager.show_dialogue_balloon(dialogue, "start")
		
		
func _spawn_player() -> CharacterBody2D:
	spawn_points = get_tree().get_nodes_in_group("spawn_points")
	if spawn_points.is_empty():
		return

	var _player = player_scene.instantiate() as CharacterBody2D
	var camera := Camera2D.new()
	_player.add_child(camera)
	camera.zoom = Vector2(3.0, 3.0)
	if get_tree().current_scene.name == "start_scene" || get_tree().current_scene.name == "end_scene":
		camera.offset = Vector2(85,0)
	
	
	_player.get_node("fish_bg").camera_node = camera
	if get_tree().current_scene.name == "level1_tank1":
		_player.scale = Vector2(0.5, 0.5)
		camera.zoom = Vector2(5.0,5.0)
		get_tree().current_scene.player_node = _player
		for child in _player.get_children():
			if is_instance_of(child, Camera2D):
				get_tree().current_scene.camera_node = child
	
	get_tree().current_scene.add_child(_player)
	_player.global_position = spawn_points[0].global_position
	
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	
	_add_minimap(_player)
	return _player
	


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
	#if current_level_index < LEVELS_LIST.size()-1:
		#var level_name = LEVELS_LIST[current_level_index + 1]
		#current_level_index += 1
		#return level_name
	#else: return LEVELS_LIST[1]
	if current_level.name == "start_scene":
		return "level1_tank1"
	elif current_level.name == "level1_tank1":
		return "level1_sewer"
	elif current_level.name == "level1_sewer":
		return "level1_boat"
	elif current_level.name == "level1_boat":
		return "end_scene"
	else:
		return "level1_tank1"
