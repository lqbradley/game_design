extends CanvasLayer

@onready var exit_marker: Sprite2D = $UI/PanelContainer/MarginContainer/SubViewportContainer/SubViewport/ExitMarker
@onready var minimap_sewer: Node2D = $UI/PanelContainer/MarginContainer/SubViewportContainer/SubViewport/minimap_sewer
@onready var sub_viewport_container: SubViewportContainer = $UI/PanelContainer/MarginContainer/SubViewportContainer
@onready var subviewport: SubViewport = $UI/PanelContainer/MarginContainer/SubViewportContainer/SubViewport
@onready var minimap_camera: Camera2D = $UI/PanelContainer/MarginContainer/SubViewportContainer/SubViewport/MinimapCamera
@onready var player_marker: Sprite2D = $UI/PanelContainer/MarginContainer/SubViewportContainer/SubViewport/MinimapCamera/PlayerMarker
@onready var goal_marker: Sprite2D = $UI/PanelContainer/MarginContainer/SubViewportContainer/SubViewport/MinimapCamera/GoalMarker


var goal_object: Node2D
var OFFSET_GOAL = 48
var OFFSET_EXIT = 100 # only for sewer
var player_node: Node2D
var minimap_tilemap

var is_scene_sewer: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set up scene
	if get_tree().current_scene.name == "level1_sewer":
		is_scene_sewer = true
		minimap_camera.zoom = Vector2(0.2,0.2)
		goal_marker.visible = false
		player_marker.scale = Vector2(0.85,0.85)
		exit_marker.visible = true
		exit_marker.scale = Vector2(1.5,1.5)
		minimap_sewer.visible = true
		goal_object = get_tree().current_scene.get_node("enter_sewer")
		
	else: 
		is_scene_sewer = false
		minimap_camera.zoom = Vector2(0.6,0.6)
		player_marker.scale = Vector2(1.0,1.0)
		exit_marker.visible = false
		minimap_sewer.visible = false
		
		for tilemap in owner.get_node("Tilemaps").get_children(): # ensure all levels with this little guy has a node called TileMaps
			minimap_tilemap = tilemap.duplicate()
			setup_minimap(minimap_tilemap)
			if tilemap.name == "background_layer": # layer with the widest reach
				var used_rect: Rect2i = tilemap.get_used_rect()
				set_minimap_limits(used_rect)
	
	
	# assign player
	player_node = get_tree().get_nodes_in_group("player")[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_node:
		var player_position
		if is_scene_sewer:
			player_position = (player_node.global_position + Vector2(650,800)) * minimap_sewer.get_node("player_trail").get_global_transform()
		else:
			player_position = player_node.global_position - Vector2(0,0)

		minimap_camera.global_position = lerp(minimap_camera.global_position, player_position, 0.2)
		player_marker.global_position = player_position
	
	if goal_object:
		var center = minimap_camera.get_screen_center_position()
		var view_size: Vector2i = ((subviewport.size as Vector2) / minimap_camera.zoom as Vector2i)
		var pos = goal_object.global_position
		if is_scene_sewer:
			pos.x = clamp(pos.x, center.x - view_size.x/2+OFFSET_EXIT, center.x + view_size.x/2 - OFFSET_EXIT)
			pos.y = clamp(pos.y, center.y - view_size.y/2+OFFSET_EXIT, center.y + view_size.y/2 - OFFSET_EXIT)
			exit_marker.global_position = pos
		else:
			pos.x = clamp(pos.x, center.x - view_size.x/2 +OFFSET_GOAL, center.x + view_size.x/2 - OFFSET_GOAL)
			pos.y = clamp(pos.y, center.y - view_size.y/2+OFFSET_GOAL, center.y + view_size.y/2 - OFFSET_GOAL)
			goal_marker.global_position = pos

func setup_minimap(minimap_tilemap: TileMapLayer) -> void:
	subviewport.add_child(minimap_tilemap)
	
func set_minimap_limits(used_rect: Rect2i) -> void:
	minimap_camera.limit_left = used_rect.position.x * 16
	minimap_camera.limit_top = used_rect.position.y * 16
	minimap_camera.limit_right = (used_rect.position.x + used_rect.size.x) * 16
	minimap_camera.limit_bottom = (used_rect.position.y + used_rect.size.y) * 16
