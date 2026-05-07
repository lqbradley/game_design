extends CharacterBody2D
@onready var acceleration = GameManager.ACCELERATION
@onready var JUMP_STYLE = GameManager.JUMP_STYLE
@onready var JUMP_VELOCITY = GameManager.JUMP_VELOCITY
@onready var MAX_SPEED = GameManager.MAX_SPEED
@onready var DASH_DISTANCE = GameManager.DASH_DISTANCE
@onready var DASH_TIME = GameManager.DASH_TIME

#const JUMP_STYLE = "hold_jump"
#const acceleration = INF
#const JUMP_VELOCITY = -500.0
#const MAX_SPEED = 350.0
var SPEED = 300.0
const MAX_HOVER_TIME = 1.5
const MAX_JUMP_HEIGHT = 160.0
const CUT_JUMP_TIME = 20
#const DASH_DISTANCE = 1000
#const DASH_TIME = 0.8
	
	
var time_passed_since_pressed_acceleration = 0
var number_already_jump: int = 0
var time_passed_since_pressed_jump = 0
var time_passed_since_pressed_dash = 0
#var JUMP_STYLE = "simple_jump"

var is_flip_h: bool = false
var is_player_dashing: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft



var JUMP_STYLE_FUNCTIONS = {
	"simple_jump" : simple_jump,
	"hold_hover"  : hold_hover, 
	"hold_jump"   : hold_jump,
	"double_jump" : double_jump
}

func _on_dash_timer_timeout() -> void:
	SPEED = 300.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle different jumps
	var jump_function = JUMP_STYLE_FUNCTIONS[JUMP_STYLE]
	jump_function.call(delta)
	
	# handle dash
	# so basically it's like a short term movement with a specific distance and/or time
	# distance can be set with the velocity formula
	var direction = Input.get_axis("move_left", "move_right")
	if Input.is_action_pressed("dash"):
		is_player_dashing = true
		var dash_timer = Timer.new()
		add_child(dash_timer)
		dash_timer.wait_time = DASH_TIME
		dash_timer.start()
		await dash_timer.timeout
		is_player_dashing = false
			
	
	#if direction == 0:
		#direction = Vector2.FORWARD
		
	
	# handle wall jump
		
	# get direction
	'''var direction = Input.get_axis("move_left", "move_right")'''
	if direction > 0 && !is_player_dashing:
		time_passed_since_pressed_acceleration += delta
		velocity.x = move_toward(velocity.x, MAX_SPEED, acceleration * time_passed_since_pressed_acceleration)
	elif direction < 0 && !is_player_dashing:
		time_passed_since_pressed_acceleration += delta
		velocity.x = move_toward(velocity.x, -MAX_SPEED, acceleration * time_passed_since_pressed_acceleration)
	elif (direction > 0 && is_player_dashing) || (direction < 0 && is_player_dashing) :
		velocity.x = direction * (DASH_DISTANCE/DASH_TIME)
	elif (direction == 0 && is_player_dashing):
		var dash_sign = -1 if is_flip_h else 1
		velocity.x = dash_sign * (DASH_DISTANCE/DASH_TIME)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_just_released("move_left") || Input.is_action_just_released("move_right"):
		time_passed_since_pressed_acceleration = 0
			# velocity.x = direction * SPEED
	
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
		is_flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		is_flip_h = true

	move_and_slide()

func hold_hover(delta):
	if Input.is_action_pressed("jump"):
		if time_passed_since_pressed_jump > MAX_HOVER_TIME:
			pass
		else: 
			time_passed_since_pressed_jump += delta
			if position.y <= MAX_JUMP_HEIGHT:
				position.y = MAX_JUMP_HEIGHT
				velocity.y = 0
			else:
				velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("jump"):
		time_passed_since_pressed_jump = 0;

func double_jump(delta):
	if number_already_jump < 2 && Input.is_action_just_pressed("jump"):
		velocity.y += JUMP_VELOCITY
		number_already_jump += 1

	if is_on_floor_only() && number_already_jump > 0:
		number_already_jump = 0

func hold_jump(delta):
	if Input.is_action_just_released("jump"):
		time_passed_since_pressed_jump = 0;
	
	if Input.is_action_pressed("jump"):
		time_passed_since_pressed_jump += delta
		velocity.y = JUMP_VELOCITY + time_passed_since_pressed_jump * CUT_JUMP_TIME

func simple_jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
