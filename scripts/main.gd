extends Node2D

# preload returns a Resource from the filesystem located at path.
var Room = preload("res://scenes/room.tscn")

# input properties for the dungeon
const TILE_SIZE = 32 # size of a tile in the tilemap
var num_rooms = 50 # no of rooms to generate
var min_size = 1 # min room size (in tiles)
var max_size = 1 # max room size (in tiles) 
const MIN_DISTANCE = TILE_SIZE * 2
# culling can make dungeon less or more sparse. 
var cull = 0.4 # chance to cull room

func _input(event):
	if event.is_action_pressed('ui_select'):
		for n in $Rooms.get_children():
			n.queue_free()
		make_rooms()

func _ready() -> void:
	# need to initialize random number generator and 
	# call function to create rooms
	$Camera2D.zoom = Vector2(0.2,0.2)
	$Camera2D.make_current()
	randomize()
	make_rooms()

func make_rooms():
	"""
	use our parameters to create randomly sized rooms
	we'll put them at (0,0)
	"""
	
	var w = 1
	var h = 1
	var room_positions = []
	
	# Step 1: Generate `n` points with normal distribution
	generate_normal_distribution_points(num_rooms, room_positions)
	
	# Step 2: Adjust points if they are too close
	adjust_points(room_positions)
	
	#print(room_positions)

	for pos in room_positions:
		var room = Room.instantiate() as RigidBody2D
		var room_size = Vector2(w, h)
		room.make_room(pos, Vector2(w, h) * TILE_SIZE)
		$Rooms.add_child(room)
	

func is_too_close(room_positions, new_pos: Vector2):
	for pos in room_positions:
		if new_pos.distance_to(pos) < MIN_DISTANCE:
			return true
	return false

func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), 
		Color(32, 228, 0), false)
		

func _process(delta: float) -> void:
	queue_redraw()

func rand_normal() -> float:
	# Box-Muller transform to get normally distributed value
	var u1 = randf_range(0.0, 1.0)
	var u2 = randf_range(0.0, 1.0)
	var z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * PI * u2)
	return z0


func generate_normal_distribution_points(n : int, points):
	# Generate `n` points using a normal distribution (Box-Muller transform)
	for i in range(n):
		var x = rand_normal() * 100.0  # scale to get spread
		var y = rand_normal() * 100.0  # scale to get spread
		points.append(Vector2(x, y))

#func adjust_points(points):
	## Step 2: Adjust points if they are too close
	#var i = 0
	#while i < points.size():
		#var p1 = points[i]
		#var j = i + 1
		#while j < points.size():
			#var p2 = points[j]
			#if p1.distance_to(p2) < TILE_SIZE * 2:
				## If points are too close, move them apart
				#p1 *= 2.0
				#p2 *= 2.0
			#j += 1
		#i += 1


func adjust_points(points):
	# Step 2: Check if any points are too close and multiply all points by 2
	for i in range(points.size()):
		var p1 = points[i]
		for j in range(i + 1, points.size()):
			var p2 = points[j]
			if p1.distance_to(p2) < TILE_SIZE * 2:
				# If any points are too close, multiply all points by 2
				for k in range(points.size()):
					points[k] *= 1.1
				#return  # We only need to multiply once, so we can stop here
