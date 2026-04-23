extends Node2D

@export var TIMER_LENGTH = 20
@onready var boundary_tilemap: TileMapLayer = $boundary_tilemap
@onready var final_area_tilemap: TileMapLayer = $final_area_tilemap
@onready var floor_tilemap: TileMapLayer = $Tilemaps/TileMapLayer
@onready var shrimp: CharacterBody2D = $shrimp

var mini_map
var floor_cells: Array[Vector2i]

# var for bounding area -> do i still need ellipse
var r_x
var r_y
var center: Vector2
var theta_ellipse
var delta_a

# variables for the spiral
var final_area: Rect2i
var start_point: Vector2i
const START_THETA: float = 20*PI
const CHANGE_THETA: float = PI/12
var current_theta: float

# moving the spiral
var final_area_center: Vector2i

var current_shrimp: CharacterBody2D = null
var viewport_main
var subviewport

func _ready() -> void:	
	# just to get bottom right corner
	var rotated_rect = boundary_tilemap.get_used_rect()
	start_point = rotated_rect.abs().end
	
	# get floorplan
	var cells = floor_tilemap.get_used_cells()
	for c in cells:
		floor_cells.append(floor_tilemap.to_global(floor_tilemap.map_to_local(c)))
	floor_cells.sort_custom(func(a, b):
		return a.x < b.x
	)
	# get boundary of ship
	theta_ellipse = boundary_tilemap.rotation
	boundary_tilemap.rotate(-theta_ellipse)
	var used_rect = boundary_tilemap.get_used_rect()
	r_x = used_rect.size.x * 16
	r_y = used_rect.size.y * 16
	center = used_rect.get_center()
	var local_center = boundary_tilemap.map_to_local(center)
	center = boundary_tilemap.to_global(local_center)
	
	# get spiral of where to spawn
	# start from the final area
	final_area = final_area_tilemap.get_used_rect()
	@warning_ignore("integer_division")
	delta_a = final_area.size.x * 16 / 2
	
	final_area_center = final_area.get_center()
	var local_center_final_area = final_area_tilemap.map_to_local(final_area_center)
	final_area_center = final_area_tilemap.to_global(local_center_final_area)

	
	current_theta = START_THETA
	
	boundary_tilemap.visible = false # remove from view
	final_area_tilemap.visible = false
	

	
	
	
	
func _physics_process(delta: float) -> void:
	while current_theta > 0:
		var bounds = spiral_bounds(current_theta)
		var r = randf_range(bounds[0], bounds[1])
		var pos = convert_to_cartesian(r, current_theta)
		if !is_part_of_ellipse(pos.x,pos.y):
			current_theta -= CHANGE_THETA
			continue
		else:
			if !is_point_in_spiral(r, current_theta) or is_point_in_wall(pos.x, pos.y):
				continue
			elif final_area.has_point(pos):
				#spawn_shrimp(pos.x, pos.y)
				shrimp.global_position = pos
				break
			else:
				#spawn_shrimp(pos.x,pos.y)
				shrimp.global_position = pos
				current_theta -= CHANGE_THETA
				await get_tree().create_timer(TIMER_LENGTH).timeout
				
		
func spawn_shrimp(x,y) -> void:
	if current_shrimp:
		current_shrimp.queue_free()
	var _shrimp = shrimp.instantiate() as CharacterBody2D
	get_tree().current_scene.add_child(_shrimp)
	_shrimp.global_position = Vector2(x,y)
	_shrimp.add_to_group("exit")
	mini_map.goal_object = _shrimp
	current_shrimp = _shrimp
	
func return_x_binary_search(x) -> int:
	# binary search
	var low = 0 
	var high = floor_cells.size() - 1 
	while low <= high:
		@warning_ignore("integer_division")
		var mid = low + (high - low) / 2
		# Check if x is present at mid
		if floor_cells[mid].x == x:
			return mid
		# If x is greater, ignore left half
		elif floor_cells[mid].x < x:
			low = mid + 1
		# If x is smaller, ignore right half
		else:
			high = mid - 1
			
	# If we reach here, then the element was not present
	return -1

func find_all_with_same_x(index) -> Array[int]:
	# returns list of indices with same x value
	var results: Array[int] = []
	var target_val = floor_cells[index].x
	var i = index
	while i >= 0 and floor_cells[i].x == target_val:
		results.append(floor_cells[i])
		i -= 1
	i = index + 1
	while i < floor_cells.size() and floor_cells[i].x == target_val:
		results.append(floor_cells[i])
		i += 1
	return results

func is_point_in_wall(x,y) -> bool:
	var index = return_x_binary_search(x)
	if index == -1:
		return false
	else:
		var indices = find_all_with_same_x(index)
		for i in indices:
			if floor_cells[i].y == y:
				return true
		return false
	
	 
func is_part_of_ellipse(x,y) -> bool:
	var res = (((x-center.x)*cos(theta_ellipse) + (y-center.y)*sin(theta_ellipse))**2)/(r_x)**2 
	res += (((x-center.x)*sin(theta_ellipse) + (y-center.y)*cos(theta_ellipse))**2)/(r_y)**2
	if res <= 1:
		return true
	return false

func convert_to_polar(x,y) -> PolarCoord:
	var r = sqrt((x^2+y^2))
	var theta = atan((y/x))
	return PolarCoord.new(r, theta)


func convert_to_cartesian(r, theta):
	var x = r * cos(theta)
	var y = r * sin(theta)
	
	# additionally, offset it so everything moves up
	y += final_area_center.y
	x += delta_a/2
	return Vector2(x,y)




func spiral_bounds(angle) -> Array[float]:	
	var lower_bound = angle*1.7
	var upper_bound = delta_a + angle*1.7
	return [lower_bound, upper_bound]
	
func is_point_in_spiral(r, theta) -> bool:
	var spiral_bounds = spiral_bounds(theta)
	if spiral_bounds[0] <= r && r <= spiral_bounds[1]:
		return true
	return false
	
class PolarCoord:
	var r: float
	var theta: float

	func _init(r: float, theta: float) -> void:
		self.r = r
		self.theta = theta
		
	
	

	
