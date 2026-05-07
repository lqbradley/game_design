extends CharacterBody2D


const SPEED = 300.0
var JUMP_VELOCITY = -250.0
@export var GRAVITY_WATER = 800
@export var GRAVITY_LAND = 980
@export var PULL_LENGTH: float = 40

@onready var collision_shape: CollisionShape2D = $player_collision
@onready var ray_cast_collide: RayCast2D = $RayCastCollide
@onready var ray_cast_pull: RayCast2D = $RayCastPull
@onready var pickup_marker: Marker2D = $pickup_marker
@onready var point_light: PointLight2D = $PointLight2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fish_bg: Node2D = $fish_bg

var r:float
var mouse_position
var number_already_jump: int = 0
var pickedObject

var current_scene


signal pulling_object_towards_player

func _ready() -> void:
	r = collision_shape.shape.get_radius()
	current_scene = get_tree().current_scene.name
	if "sewer" in current_scene:
		point_light.visible = true
		fish_bg.visible = false
	else:
		point_light.visible = false
		fish_bg.visible = true
	
	
func _physics_process(delta: float) -> void:
	
	# in sewer scenes remove gravity
	if "sewer" in current_scene:
		var y_dir := Input.get_axis("move_up", "move_down")
		if y_dir:
			velocity.y = y_dir * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		# Add the gravity.
		if not is_on_floor():
			velocity.y += GRAVITY_WATER * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			sprite.flip_h = false
		if direction < 0:
			sprite.flip_h = true
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# picking up object
	if pickedObject:
		pickedObject.position = pickup_marker.global_position
	
	if Input.is_action_just_released("pick_up"):
		pickedObject = null
		
	
	# crouch
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		collision_shape.shape.set_radius(r/2)
	
	if Input.is_action_just_released("crouch") and is_on_floor():
		collision_shape.shape.set_radius(collision_shape.shape.get_radius()*2)
	
	# pull object by clicking a mouse
	if Input.is_action_pressed("pull"):
		var space_state = get_world_2d().direct_space_state
		mouse_position = get_global_mouse_position()
		
		var origin = global_position # current position of player
		var pull_dir = (mouse_position - origin).normalized()
		var end = origin + pull_dir * PULL_LENGTH
		
		var query = PhysicsRayQueryParameters2D.create(origin, end)
		# query.collide_with_areas = true
		
		var result = space_state.intersect_ray(query)
		
		if result.has("collider"):
			# move object towards player
			if result.collider.is_in_group("to_player"):
				result.collider.apply_central_impulse(-pull_dir * 2 * origin.distance_to(end))
				print("pullable")
			# move player towards object
			if result.collider.is_in_group("to_object"):
				velocity = pull_dir * 2 * origin.distance_to(end)
				print("pulling")
		
	

	move_and_slide()


func double_jump():
	if number_already_jump < 2 && Input.is_action_just_pressed("jump"):
		velocity.y += JUMP_VELOCITY
		number_already_jump += 1

	if is_on_floor_only() && number_already_jump > 0:
		number_already_jump = 0	


func _on_push_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("pushable_object"):
		body.collision_layer = 1
		body.collision_mask = 1


func _on_push_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("pushable_object"):
		body.collision_layer = 2
		body.collision_mask = 2


func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("pickup_able") && Input.is_action_pressed("pick_up"):
		body.position = pickup_marker.global_position
		pickedObject = body
		body.collision_mask = 2
		body.collision_layer = 2



func _on_pick_up_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("pickup_able") && !Input.is_action_pressed("pick_up"):
		body.position = body.global_position
		body.apply_central_force(Vector2(0, GRAVITY_WATER))
		pickedObject = null
		body.collision_mask = 3
		body.collision_layer = 3




func _on_object_area_body_entered(body: Node2D) -> void:
	if body is TileMapLayer && pickedObject:
		pickedObject = null
		


func _on_object_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
