extends Node2D
#@onready var markers: Node = $"../../../../../../Tilemap Layers/Markers"
@onready var player_trail: TileMapLayer = $player_trail
@onready var subviewport: SubViewport = $".."

var player_positions: Array[Vector2i]
var all_markers_world: Array[MapSection] # why does godot not have tuples??
var all_markers_local: Array[MapSection]
var player

var previous_player_positions: Array[Vector2i]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# setting up the grids
	'''
	for layer in markers.get_children():
		var used_cells = layer.get_used_cells()
		var tmp = []
		var section_world: MapSection
		var section_local: MapSection
		for c in used_cells:
			var pos = layer.to_global(layer.map_to_local(c))
			tmp.append(pos)
		section_world = MapSection.new(tmp[0], tmp[1])
		section_local = MapSection.new(used_cells[0], used_cells[1])
		all_markers_world.append(section_world)
		all_markers_local.append(section_local)
		layer.visible = false	
	'''
	player = get_tree().get_nodes_in_group("player")[0]
	#mini_map.visible = false
	#player_trail2.scale = Vector2(0.5, 0.5)
	player_trail.scale = Vector2(0.5, 0.5) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#var player_position = (player.global_position) 
	var player_position = (player.global_position + Vector2(650,800)) * player_trail.get_global_transform() 
	var local_pos = player_trail.to_local(player_position)
	var pos_in_tilemap = player_trail.local_to_map(player_trail.to_local(player_position))
	player_trail.set_cell(pos_in_tilemap, 0, Vector2(15,1), 0)
		
func _set_section_visible() -> void:
	# get the previous locations of the player on the map
	pass

class MapSection:
	var start: Vector2i
	var end: Vector2i
	
	func _init(_start: Vector2i, _end: Vector2i):
		start = _start
		end = _end
