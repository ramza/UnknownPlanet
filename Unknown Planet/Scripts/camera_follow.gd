extends Camera2D
# onready prefix : Initializes a variable once the Node the script is attached to and its children are part of the scene tree.
var target_node
export var forward_offset = 30
export var x_smoothing = .05
export var max_y_offset = 5
export var y_smoothing = .1
export var x_lock = false
export var y_lock = false

var _duration = 0
var _period_in_ms = 0
var _amplitude = 0
var _timer = 0
var _last_shook_timer = 0
var _previous_x = 0
var _previous_y = 0
var _last_offset = Vector2(0, 0)
var is_shaking = false

var start_x
var start_y

func _ready():
	set_process(true)
	
func start_camera(target):
	# window maximized, comment this line code if you don't want to automatically maximized

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
	
func _process(delta):
    # Only shake when there's shake time remaining.
    if _timer == 0:
        return
    # Only shake on certain frames.
    _last_shook_timer = _last_shook_timer + delta
    # Be mathematically correct in the face of lag; usually only happens once.
    while _last_shook_timer >= _period_in_ms:
        _last_shook_timer = _last_shook_timer - _period_in_ms
        # Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
        var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
        # Noise calculation logic from http://jonny.morrill.me/blog/view/14
        var new_x = rand_range(-1.0, 1.0)
        var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
        var new_y = rand_range(-1.0, 1.0)
        var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
        _previous_x = new_x
        _previous_y = new_y
        # Track how much we've moved the offset, as opposed to other effects.
        var new_offset = Vector2(x_component, y_component)
        set_offset(get_offset() - _last_offset + new_offset)
        _last_offset = new_offset
    # Reset the offset when we're done shaking.
    _timer = _timer - delta
    if _timer <= 0:
        _timer = 0
        is_shaking = false
        set_offset(get_offset() - _last_offset)

# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude):
    is_shaking = true
    # Initialize variables.
    _duration = duration
    _timer = duration
    _period_in_ms = 1.0 / frequency
    _amplitude = amplitude
    _previous_x = rand_range(-1.0, 1.0)
    _previous_y = rand_range(-1.0, 1.0)
    # Reset previous offset, if any.
    set_offset(get_offset() - _last_offset)
    _last_offset = Vector2(0, 0)