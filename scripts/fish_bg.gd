extends Node2D

@onready var swordfish: AnimatedSprite2D = $swordfish
@onready var whales: Node2D = $whales
@onready var fish: Node = $fish

@export var SPEED_FISH: float = 50
@export var SPEED_WHALE: float = 35

var rng = RandomNumberGenerator.new()
var viewport
var camera_node
var new_fish
var old_fish

var next_fish_here: bool = false
const MAX_WHALES: int = 5

func _ready() -> void:
	swordfish.flip_h = true
	viewport = get_viewport()
	
	rng.randomize()
	
	randomize_z(whales)
	randomize_z(fish)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for f in fish.get_children():
		f.position.x -= SPEED_FISH * delta
	if new_fish:
		for f in new_fish.get_children():
			f.position.x -= SPEED_FISH * delta
	
	for whale in whales.get_children():
		whale.position.x += SPEED_WHALE * delta
	
	var center = camera_node.get_screen_center_position()
	var view_size: Vector2i = ((viewport.size as Vector2) / camera_node.zoom as Vector2i)
	var first_rect: Rect2 = fish.get_children()[0].get_rect()
	var last_rect: Rect2 = fish.get_children()[-1].get_rect()
	
	var top_left: Vector2 = fish.get_children()[0].to_global(first_rect.position)
	var bottom_right: Vector2 = fish.get_children()[-1].to_global(last_rect.end)
	var left_x = center.x - view_size.x/2
	var right_x = center.x + view_size.x/2
	var top_y = center.y - view_size.y/2
	var bottom_y = center.y + view_size.y/2

	if top_left.x < left_x and !next_fish_here:
		next_fish_here = true
		new_fish = fish.duplicate()
		new_fish.name = "new_fish"
		randomize_z(new_fish)
		add_child(new_fish)
		new_fish.global_position = Vector2(bottom_right.x, top_left.y)
	if bottom_right.x < left_x and new_fish != null:
		old_fish = fish
		fish = new_fish
		new_fish = null
		next_fish_here = false
		old_fish.queue_free()
		fish.name = "fish"
	
	for whale in whales.get_children():
		if whale.global_position.x > right_x:
			await get_tree().create_timer(2.0).timeout
			if whales.get_child_count() < MAX_WHALES:
				var new_whale = whale.duplicate()
				new_whale.z_index = randf_range(0,4)
				whales.add_child(new_whale)
				new_whale.global_position = Vector2(
					randf_range(left_x-80, left_x),
					randf_range(top_y, bottom_y)
				)
			
		continue
	
func start_tween():
	# tween for fish_bg
	var fish_tween = get_tree().create_tween()
	fish_tween.set_loops() # infinite
	fish_tween.set_trans(Tween.TRANS_LINEAR)
	#fish_tween.tween_property(fishies, "position:x", position.x - (2.0 * SPEED_FISH), 2.0)
		
	var whale_tween = get_tree().create_tween()
	whale_tween.set_loops()
	whale_tween.set_trans(Tween.TRANS_LINEAR)
	#whale_tween.tween_property(whale, "position:x", position.x - (2.0 * SPEED_WHALE), 2.0)
		
		
func randomize_z(parent: Node2D):
	for item in parent.get_children():
		item.z_index = randf_range(0,4)
		
