extends Node2D

# preload returns a Resource from the filesystem located at path.
var Room = preload("res://scenes/room.tscn")

# input properties for the dungeon
const TILE_SIZE = 32 # size of a tile in the tilemap
var num_rooms = 50 # no of rooms to generate
var min_size = 1 # min room size (in tiles)
var max_size = 1 # max room size (in tiles) 
const MIN_DISTANCE = TILE_SIZE * 2

var path: AStar3D  # AStar pathfinding object

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
	
	var room_positions_3d = []
	

	for pos in room_positions:
		var room = Room.instantiate() as RigidBody2D
		var room_size = Vector2(w, h)
		room.make_room(pos, Vector2(w, h) * TILE_SIZE)
		$Rooms.add_child(room)
		room_positions_3d.append(Vector3(room.position.x, room.position.y, 0))
		#path = find_mst(room_positions_3d)
	path = find_mst(room_positions_3d)

func find_mst(nodes: Array):
	# Prim's algorithm
	# Given an array of positions(nodes), generate a minimum 
	# spanning tree
	
	# Initializes the Astar and add the first point
	var path = AStar3D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	# repeats until no points remain
	while nodes: 
		var min_dist = INF
		var min_p = null # position of that node
		var p = null # current position
		
		# loop through the points in path
		for p1 in path.get_point_ids():
			var p1_pos = path.get_point_position(p1)
			# loop through the remaining nodes
			for p2 in nodes:
				# if the node is closer, make it closest
				if p1_pos.distance_to(p2) < min_dist:
					min_dist = p1_pos.distance_to(p2)
					min_p = p2
					p = p1_pos
		
		# insert the resulting node to the path and add 
		# its connection
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		# remove the nodes in the array so that it is not visited again
		nodes.erase(min_p)
	return path

func is_too_close(room_positions, new_pos: Vector2):
	for pos in room_positions:
		if new_pos.distance_to(pos) < MIN_DISTANCE:
			return true
	return false

func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), 
		Color(32, 228, 0), false)
		
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), 
				Color(1, 1, 0, 1), 15, true)

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
