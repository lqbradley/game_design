extends Node2D

# alrighty let's see if i can do this

@export var num_mantarays: int= 5
var mantaray := preload("res://scenes/objects/mantaray.tscn")
var rng = RandomNumberGenerator.new()
var all_mantarays = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0, num_mantarays):
		var temp = mantaray.instantiate()
		add_child(temp)		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _determine_next_position(array: Array[Mantaray]) -> Array[Mantaray]:
	# if there is a player, limit the movement directions
	return []
	
class Mantaray:
	var name : String
	var current_position: Vector2
	var time_needed: float
	var current_direction_y: bool # -1 for up, 1 for down
	var current_direction_x: bool # -1 for left, 1 for right
	var next_position: Vector2
	var has_player: bool
	var node_reference: AnimatableBody2D
