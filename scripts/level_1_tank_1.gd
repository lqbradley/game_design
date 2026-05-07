extends Node2D

@export var RANDOM_SHAKE_STRENGTH: float = 30.0
@export var SHAKE_DECAY_RATE: float = 5.0

@onready var rand = RandomNumberGenerator.new()
@onready var brains: Node = $brains
@onready var goldfish: AnimatedSprite2D = $goldfish
@onready var inventory: Label = $CanvasLayer/brain_counter/Inventory
@onready var lever_tutorial: Area2D = $lever_tutorial

const REQUIRED: int = 7
var num_collected: int = 0
var shake_strength : float = 0.0
var player_node
var camera_node
var exit_lock:= false

signal enoughCollected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for b in brains.get_children():
		b.brain_collected.connect(_on_collected)
	inventory.text = str(num_collected)
	
	goldfish.playerArrived.connect(_on_exit_attempt)
	goldfish.reactivateDoor.connect(_on_player_leave)
	
	rand.randomize()
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	lever_tutorial.body_entered.connect(_on_lever_tutorial_body_entered)


func _on_dialogue_ended(resource) -> void:
	player_node.process_mode = Node.PROCESS_MODE_PAUSABLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	camera_node.offset = get_random_offset()
	
	if num_collected >= REQUIRED:
		enoughCollected.emit()
		goldfish.is_enough_collected = true

func _on_player_leave() -> void:
	await get_tree().create_timer(3.0).timeout
	exit_lock = false
	inventory.add_theme_color_override("font_color", Color("#ffffff"))


func _on_collected() -> void:
	num_collected += 1
	inventory.text = str(num_collected)
	
func _on_exit_attempt():
	if exit_lock == true:
		return
	else:
		exit_lock = true
		inventory.add_theme_color_override("font_color", Color("#54221f"))
		apply_shake()
		player_node.process_mode = Node.PROCESS_MODE_DISABLED
		var reminder_text = "~ start
Oops
Remeber that you need [b]SEVEN[/b] to leave
See how many you have already collected in the top right corner"
		var dialogue = DialogueManager.create_resource_from_text(reminder_text)
		DialogueManager.show_dialogue_balloon(dialogue, "start")
		#goldfish.playerArrived.disconnect(_on_exit_attempt)
	
	
func apply_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
	
func _on_lever_tutorial_body_entered(body: Node2D) -> void:
		if not body.is_in_group("player"):
			return
		if body is CharacterBody2D:
			player_node.process_mode = Node.PROCESS_MODE_DISABLED
			var tutorial_text = """~ start
Levers need to be pushed for the moving platforms to activate
Keep moving in the direction you want to push it in.
Levers can sometimes be heavy so make sure you keep on pushing. Letting go resets your progress"""
			var dialogue = DialogueManager.create_resource_from_text(tutorial_text)
			DialogueManager.show_dialogue_balloon(dialogue, "start")
			lever_tutorial.body_entered.disconnect(_on_lever_tutorial_body_entered)
