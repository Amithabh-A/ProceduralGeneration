extends RigidBody2D

# size property, which will be able to randomize
# it can be used for make_room() to generate 
# RectangleShape2D for collision
var size

 
func make_room(_pos, _size):
	"""
	make RectangleShape2D for collision
	"""
	#_pos = ? _size = ? 
	position = _pos
	size = _size
	# A 2D rectangle shape used for physics collision.
	var s = RectangleShape2D.new()
	s.extents = size # no idea
	$CollisionShape2D.shape = s

func _ready() -> void:
	self.lock_rotation = true
#
#
#func _process(delta: float) -> void:
	#pass
