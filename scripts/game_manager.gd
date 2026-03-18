extends Node


var ACCELERATION
var MAX_SPEED
var JUMP_VELOCITY
var JUMP_HEIGHT
var JUMP_STYLE

const SCENARIOS = {
	"ACCELERATION": [5,10,INF],
	"MAX_SPEED": [500,800,1000],
	"JUMP_VELOCITY": [],
	"JUMP_HEIGHT": [30,50,100],
	"JUMP_STYLE": ["simple_jump", "hold_hover", "hold_jump", "double_jump"]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var acc_test_cases = generate_test_case("ACCELERATION", [5,10,20])
	#start_test_case(acc_test_cases)
	pass

func _on_timer_timeout():
	get_tree().reload_current_scene()

# should pass a structure of function and input
# so of the format {"function": , "input": }
func start_test_case(fs: Array[TestCase]) -> void:
	for x in fs:
		for child in get_children():
			if child is Timer:
				child.queue_free()
				
		var callable = x.Function
		callable.call(x.VarName, x.Inputs)
		
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 2.0
		timer.start()
		timer.timeout.connect(_on_timer_timeout)
		print(ACCELERATION)
		await timer.timeout

func set_var(variable_name: String, val: float)->void:
	set(variable_name, val)

func generate_test_case(variable_name: String, values: Array) -> Array:
	var test_cases: Array[TestCase] = []
	for v in values:
		var a = TestCase.new()
		a.Function = set_var
		a.VarName = variable_name
		a.Inputs = v
		test_cases.append(a)
	return test_cases 

func set_acceleration(acc: float)->void:
	ACCELERATION = acc
	
func test_case_acceleration(acs: Array) -> Array:
	var acceleration_test_case: Array[TestCase] = []
	for acceleration in acs:
		var a = TestCase.new()
		a.Function = set_acceleration
		a.Inputs = acceleration
		acceleration_test_case.append(a)
	return acceleration_test_case


class TestCase:
	var Function: Callable
	var VarName: String
	var Inputs: Variant # should be type any but it's not there??
	
class PlayerDefaults:
	var Acceleration: float
	var MaxSpeed: float

		
		

		
