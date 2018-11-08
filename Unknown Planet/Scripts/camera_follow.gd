extends Camera2D
# onready prefix : Initializes a variable once the Node the script is attached to and its children are part of the scene tree.
var target_node
export var forward_offset = 30
export var x_smoothing = .05
export var max_y_offset = 5
export var y_smoothing = .1
export var x_lock = false
export var y_lock = false

var start_x
var start_y

func _ready():
	pass
	
func start_camera(target):
	# window maximized, comment this line code if you don't want to automatically maximized
	OS.set_window_maximized(true)
	target_node = game_manager.player
	var pos = target_node.get_pos()
	# forcing set the position into character position
	pos = Vector2(round(pos.x), round(pos.y))
	set_pos(pos)
	start_x = pos.x
	start_y = pos.y
	set_fixed_process(true)

func _fixed_process(delta):
	var target_pos = target_node.get_center_pos() + Vector2(1, 0) * target_node.velocity.normalized().x * forward_offset
	# smoothing the movement
	target_pos.x = lerp(get_pos().x, target_pos.x, x_smoothing)
	#gap it when the next position is out of bound
	if abs(target_pos.x - target_node.get_center_pos().x) > forward_offset:
		target_pos.x = target_node.get_center_pos().x + target_node.facing_dir * forward_offset * -1
	# set the position into integer number
	var new_pos = Vector2(round(target_pos.x), round(target_pos.y))
	if x_lock:
		set_pos(Vector2(start_x, round(target_pos.y)))
	elif y_lock:
		set_pos(Vector2(round(target_pos.x), start_y))
	else:
		set_pos(Vector2(round(target_pos.x), round(target_pos.y)))


	if abs(target_pos.x - target_node.get_center_pos().x) > forward_offset:
		target_pos.x = target_node.get_center_pos().x + target_node.facing_dir * forward_offset * -1
	
	target_pos.y = lerp(get_pos().y, target_pos.y + max_y_offset, y_smoothing)
	if abs(target_pos.y - target_node.get_center_pos().y) > max_y_offset:
		target_pos.y =  target_node.get_center_pos().y + (sign(target_pos.y - target_node.get_center_pos().y) * max_y_offset)
	
	#set_pos(Vector2(round(target_pos.x), round(target_pos.y)))