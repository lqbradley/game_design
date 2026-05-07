extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var jumpReloadRate = 100

signal hasJumped
@export var maxTimeToJump = 300
@onready var currentTimeToJump: float = maxTimeToJump
@onready var ray_cast_down: RayCast2D = $RayCastDown

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray: RayCast2D = $CollisionShape2D/WallRay
@onready var jump_bar: ProgressBar = $JumpBar

const MAX_SPEED: float = 64.5 # only for horizontal 
const ACCELERATION: float = 18.5
const FRICTION: float = 22.5

const GRAVITY_NORMAL: float = 14.5  # not sliding on wall
const GRAVITY_WALL: float = 8.5		# gravity when sliding on wall	# og value: 8.5
const WALL_JUMP_PUSH_FORCE: float = 100.0

var wall_contact_coyote: float = 0.0 # timer how long consider player is still on the wall
const WALL_CONTACT_COYOTE_TIME: float = 0.2

var wall_jump_lock: float = 0.0 # how long we lower acceleration of friction
const WALL_JUMP_LOCK_TIME: float = 0.05

var look_dir_x: int = 1		# direction player is looking when on wall

const CLIMB_SPEED:float = 26.5
const CLIMB_EXIT_BOOST: Vector2 = Vector2(100,-100)	# boost when climbing on top of a wall
var is_climbing: bool = false

# position stamina bar so it's not behind a wall
const JUMP_BAR_POS_LEFT: float = -7
const ST_BAR_POS_RIGHT: float = 4

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() || is_on_wall():
		velocity += get_gravity() * delta
	
	player_jump(delta)
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	

func physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor() || is_on_wall():
		#velocity += get_gravity() * delta
	#
	#player_jump(delta)
	#
	if velocity.x:
		wall_ray.target_position.x = 16 * sign(velocity.x)
	var on_wall: bool = wall_ray.is_colliding() and wall_ray.get_collider() is TileMapLayer
	var on_wall_in_air: bool = on_wall and !is_on_floor() 
	
	# movement
	var x_direction := Input.get_axis("move_left", "move_right")
	if !is_climbing:
		#if wall_jump_lock > 0.0:
			#wall_jump_lock -= delta
		var velocity_weight_x: float = 1.0 - exp(-(ACCELERATION if x_direction else FRICTION) * delta)
		var weight_mod: float = 0.5 if wall_jump_lock > 0.0 else 1.0
		velocity.x = lerp(velocity.x, x_direction * MAX_SPEED, velocity_weight_x * weight_mod)
		#if x_direction:
			#velocity.x = x_direction * SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if on_wall_in_air and velocity.y > 0:	# is currently falling
			wall_contact_coyote = WALL_CONTACT_COYOTE_TIME # set timer so player can still jump
			look_dir_x = int(-wall_ray.get_collision_normal().x)  # get_collision_normal = -1 if hit from right, 1 if hit from left
			
			if x_direction or Input.is_action_pressed("move_up"):
				velocity.y = GRAVITY_WALL
			else:
				velocity.y += GRAVITY_NORMAL
		else: # if player is not currently falling
			#if wall_contact_coyote > 0.0:
				#wall_contact_coyote -= delta
			velocity.y += GRAVITY_NORMAL
		
		if (is_on_floor() or wall_contact_coyote > 0.0) and Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			if wall_contact_coyote > 0.0 and !is_on_floor():	# player jumping from wall 
				velocity.x = -look_dir_x * WALL_JUMP_PUSH_FORCE
				wall_jump_lock = WALL_JUMP_LOCK_TIME
	
	if wall_contact_coyote > 0.0 or is_climbing:
		#if Input.is_action_pressed("jump") and climb_stamina_timer > 0.0 and on_wall_in_air:
		if Input.is_action_pressed("jump") and on_wall_in_air:
			is_climbing = true
			#wall_jump_lock = 0.0 # stop it counting down
			
			var y_input: float = Input.get_axis("move_up", "move_down")
			var velocity_weight_y: float = 1.0 - exp(-(ACCELERATION if y_input else FRICTION) * delta)
			velocity.y = lerp(velocity.y, y_input * CLIMB_SPEED, velocity_weight_y)
			
			#var drain_rate: float = CLIMB_STAMINA_DRAIN if y_input else 1.0
			#climb_stamina_timer -= delta * drain_rate
		else:
			if !on_wall and !is_on_floor() and is_climbing:
				velocity.y = CLIMB_EXIT_BOOST.y
				if !x_direction:
					velocity.x = CLIMB_EXIT_BOOST.x * look_dir_x
				is_climbing = false
	#if is_on_floor():
		#climb_stamina_timer = STAMINA_AMT
		
	move_and_slide()
	_animation(x_direction, on_wall)

func _animation(x_input: float, on_wall: bool) -> void:
	if !is_climbing and x_input:
		animated_sprite.flip_h = x_input < 0
	if is_climbing or (on_wall and (x_input or Input.is_action_pressed("jump"))):
		var move_climbing: bool = is_climbing and Input.get_axis("move_up", "move_down")
		
	

func player_jump(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()) and currentTimeToJump >= maxTimeToJump :
		velocity.y = JUMP_VELOCITY
		currentTimeToJump = 0
	if currentTimeToJump < maxTimeToJump:
		currentTimeToJump += delta * jumpReloadRate
	else:
		currentTimeToJump = maxTimeToJump
