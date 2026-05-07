extends AnimatedSprite2D

signal activate_object
var object_to_be_activated
@onready var influence_area: Area2D = $influence_area
@onready var player_move_area: Area2D = $player_move_area
@onready var lever: AnimatedSprite2D = $"."

var time_to_switch: float
var is_on: bool
var rng = RandomNumberGenerator.new()
var pushing_time: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_to_switch = rng.randf_range(0.5,1.5)
	influence_area.monitoring = true
	
	await get_tree().process_frame
	for obj in influence_area.get_overlapping_bodies():
		if obj.is_in_group("activate_able"):
			object_to_be_activated = obj
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for obj in player_move_area.get_overlapping_bodies():
		if obj is CharacterBody2D:
			# now check for direction of travel
			var dir := Input.get_axis("move_left", "move_right")
			if dir > 0 && !is_on: # player moving right and lever is on the left
				pushing_time += delta
				if pushing_time > time_to_switch:
					activate_lever()
			elif dir < 0 && is_on:
				pushing_time += delta
				if pushing_time > time_to_switch:
					deactivate_lever()
			elif dir == 0:
				pushing_time = 0 # reset if not pushing
				
func activate_lever():
	is_on = true
	lever.animation = "activate"
	lever.play()
	object_to_be_activated.get_node("AnimationPlayer").play("move")

func deactivate_lever():
	is_on = false
	lever.animation = "deactivate"
	lever.play()
	object_to_be_activated.get_node("AnimationPlayer").stop()
			
func _animation() -> void:
	if is_on:
		lever.animation = "activate"
		lever.play()
	
		
