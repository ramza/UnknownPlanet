extends KinematicBody2D

var can_act = true
var explosion = preload("res://Scenes/small_explosion.tscn")
export var hp = 5
export var damage = 1
var player 

onready var state_machine = get_node("EnemyStateMachine")
onready var sprite = get_node("Sprite")
onready var timer = get_node("Timer")
onready var rightcast = get_node("RightCast")
onready var leftcast2 = get_node("LeftCast2")
onready var leftcast = get_node("LeftCast")
onready var left_footcast = get_node("LeftFootCast")
onready var right_footcast = get_node("RightFootCast")
onready var sample_plyr = get_node("SamplePlayer2D")

const GRAVITY = 500.0 # Pixels/second
var max_player_range
# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 100
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 30

const STOP_FORCE = 1300
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false
export var speed = 1
var prev_jump_pressed = false

export var overrun = false

func take_damage(damage):
	hp -= damage
	sample_plyr.play("hurt")
	if (!overrun):
		can_act = false
		
		timer.start()
		state_machine.hurt()
	if hp <= 0:
		death()
		
	
func death():
	var new_explosion = explosion.instance()
	new_explosion.set_pos(self.get_pos())
	get_parent().add_child(new_explosion)
	queue_free()
	
func walk_right():
	if rightcast.is_colliding():
		
		var body = rightcast.get_collider()
		#print("hit a " + body.get_name())
		if body.is_in_group("player"):
			return true
	return false
	
func walk_left():
	if leftcast.is_colliding():
		var body = leftcast.get_collider()
		if body != null and body.is_in_group("player"):
			return true
	if leftcast2.is_colliding():
		var body = leftcast2.get_collider()
		if body != null and body.is_in_group("player"):
			return true
			
	return false

func _fixed_process(delta):
	# Create forces
	var force = Vector2(0, GRAVITY)
	
	var walk_left = walk_left()
	var walk_right = walk_right()
	var jump = false
	
	var stop = true
	
	if (walk_left and can_act and left_footcast.is_colliding()):
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
			state_machine.walk()
			sprite.set_scale(Vector2(1,1))
	elif (walk_right and can_act and right_footcast.is_colliding()):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
			state_machine.walk()
			sprite.set_scale(Vector2(-1,1))
	if (stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	if velocity.x == 0 and velocity.y == 0:
		if state_machine.state != state_machine.STATES.HURT:
			state_machine.idle()
	# Integrate forces to velocity
	velocity += force*delta
	
	# Integrate velocity into motion and move
	var motion = velocity*speed*delta
	
	# Move and consume motion
	motion = move(motion)
	
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		# You can check which tile was collision against with this
		# print(get_collider_metadata())
		
		# Ran against something, is it the floor? Get normal
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			# If angle to the "up" vectors is < angle tolerance
			# char is on floor
			on_air_time = 0
			floor_velocity = get_collider_velocity()
		
		if (on_air_time == 0 and force.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
	
			revert_motion()
			velocity.y = 0.0
		else:
			# For every other case of motion, our motion was interrupted.
			# Try to complete the motion by "sliding" by the normal
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			# Then move again
			move(motion)
	
	if (floor_velocity != Vector2()):
		# If floor moves, move with floor
		move(floor_velocity*delta)
	
	if (jumping and velocity.y > 0):
		# If falling, no longer jumping
		jumping = false
	
	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping):
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true
	
	on_air_time += delta
	prev_jump_pressed = jump
	state_machine.do_animation()

func contact():
	state_machine.hurt()
	
func disable():
	set_fixed_process(false)
	get_node("CollisionShape2D").set_trigger(true)
	state_machine.idle()
	can_act = false
	
func on_enemy_timer_timeout():
	timer.stop()
	if state_machine.state != state_machine.STATES.HURT:
		state_machine.idle()
		
	can_act = true
	
func on_body_enter(body):
	pass
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer.connect("timeout", self, "on_enemy_timer_timeout")
	state_machine.idle()
	player = game_manager.player
	set_fixed_process(true)
