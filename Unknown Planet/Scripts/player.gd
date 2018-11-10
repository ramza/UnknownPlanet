
extends KinematicBody2D


# This is a simple collision demo showing how
# the kinematic controller works.
# move() will allow to move the node, and will
# always move it to a non-colliding spot,
# as long as it starts from a non-colliding spot too.
var dust = preload("res://Scenes/dust.tscn")
# Member variables
const GRAVITY = 500.0 # Pixels/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 50
const WALK_FORCE = 300
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 100
const STOP_FORCE = 1300
const JUMP_SPEED = 140
const JUMP_BONUS = 7
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

var jumping = false
var velocity = Vector2(0,0)
var on_air_time = 100
var prev_jump_pressed = false

var can_act = true
var facing_dir = 1
var gun_distance = 8
var hp = 3
var max_hp = 3
var grounded = false
var on_ladder = false

onready var sprite = get_node("Sprite")
onready var gun = get_node("LaserGun")
onready var timer = get_node("Timer")
onready var area = get_node("Area2D")
onready var state_machine = get_node("PlayerStateMachine")
onready var raycast = get_node("RayCast2D")
onready var leftCast = get_node("LeftCast")
onready var rightCast = get_node("RightCast")
onready var steps_timer= get_node("Steps_Timer")

func _fixed_process(delta):
	standard_movement(delta)
	
	state_machine.do_animation()
	
func standard_movement(delta):
		# Create forces
	var force = Vector2(0, GRAVITY)
	
	var walk_left = Input.is_action_pressed("move_left") and can_act
	var walk_right = Input.is_action_pressed("move_right") and can_act
	var jump = Input.is_action_pressed("jump") and can_act
	
	var stop = true
	
	if (walk_left):
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
			facing_dir = -1
			
	elif (walk_right):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
			facing_dir = 1
		
			
	sprite.set_scale(Vector2(facing_dir,1))
	gun.set_pos(Vector2(facing_dir*gun_distance, 1))
	
	if jumping and jump and on_air_time < 0.3:
		velocity.y -= JUMP_BONUS
		
	if grounded and !walk_right and !walk_left and not state_machine.state == state_machine.STATES.HURT and can_act:
		if Input.is_action_pressed("fire"):
			state_machine.shoot()
		else:
			state_machine.idle()
			steps_timer.steps_on = false
	elif walk_left or walk_right:
		if ( state_machine.state != state_machine.STATES.JUMP and state_machine.state != state_machine.STATES.FALL):
				state_machine.walk()
				steps_timer.steps_on = true
	
	if (stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	# Integrate forces to velocity
	velocity += force*delta
	
	if !jumping and !grounded and velocity.y > 0 and state_machine.state != state_machine.STATES.DEAD:
		state_machine.fall()
		steps_timer.steps_on = false
	
	# Integrate velocity into motion and move
	var motion = velocity*delta
	
	# Move and consume motion
	motion = move(motion)
	
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		var body = get_collider()
		# You can check which tile was collision against with this
		# print(get_collider_metadata())
		
		# Ran against something, is it the floor? Get normal
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			# If angle to the "up" vectors is < angle tolerance
			# char is on floor
			if state_machine.state == state_machine.STATES.JUMP or state_machine.state == state_machine.STATES.FALL:
				state_machine.idle()
			
			if !grounded and !leftCast.is_colliding() and !rightCast.is_colliding():
				if state_machine.state != state_machine.STATES.DEAD:
					place_dust()
					steps_timer.play_landing_sound()
				
			grounded = true
			on_air_time = 0
			floor_velocity = get_collider_velocity()
		
		
		if (on_air_time == 0 and force.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			# Since this formula will always slide the character around, 
			# a special case must be considered to to stop it from moving 
			# if standing on an inclined floor. Conditions are:
			# 1) Standing on floor (on_air_time == 0)
			# 2) Did not move more than one pixel (get_travel().length() < SLIDE_STOP_MIN_TRAVEL)
			# 3) Not moving horizontally (abs(velocity.x) < SLIDE_STOP_VELOCITY)
			# 4) Collider is not moving
			
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
	
	if !jumping and velocity.y > 0 and grounded:
		grounded = false
	
	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping):
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true
		grounded = false
		state_machine.jump()
		steps_timer.steps_on = false
		steps_timer.play_jump_sound()
	
	on_air_time += delta
	prev_jump_pressed = jump
	
func place_dust():
	var d = dust.instance()
	game_manager.current_scene.add_child(d)
	d.set_global_pos(Vector2(get_global_pos().x, get_global_pos().y-4))

func knockback(enemy):
	if enemy.get_pos().x > get_pos().x:
		velocity.x = -300
		
	elif enemy.get_pos().x < get_pos().x:
		velocity.x = 300
	
	else:
		velocity.y = -300

func get_center_pos():
	return get_pos() + get_node("CollisionShape2D").get_pos()

func death():
	game_manager.spawnpoint = 1
	timer.stop()
	steps_timer.play_death_sound()
	state_machine.dead()
	steps_timer.steps_on = false
	disable()
	game_manager.HUD.reset_level()
	game_manager.health = 3
	game_manager.ammo = 25
	
func disable():
	can_act = false
	if state_machine.state != state_machine.STATES.DEAD:
		state_machine.idle()
	steps_timer.steps_on = false
	gun.can_fire = false
	
	
func enable():
	can_act = true
	gun.can_fire = true
	
func take_damage(body, dmg):
	hp -= dmg
	state_machine.hurt()
	can_act = false
	steps_timer.play_hurt_sound()
	if hp > 0:
		knockback(body)
		timer.start()
	else:
		death()
	update_healthbar()

func update_healthbar():
	game_manager.HUD.update_healthbar(hp/float(max_hp))
	
func on_player_timer_timerout():
	timer.stop()
	can_act = true
	if state_machine.state == state_machine.STATES.HURT:
		state_machine.idle()
		
func add_ammo(amount):
	gun.add_ammo(amount)
	
func add_health(amount):
	hp += 1
	if hp > max_hp:
		hp = max_hp
	update_healthbar()
	
func flip():
	facing_dir = -1
	sprite.set_scale(Vector2(facing_dir,1))
	gun.set_pos(Vector2(facing_dir*gun_distance, 1))
	
func on_player_body_enter(body):
	if body.is_in_group("enemy"):
		take_damage(body, 1)
		if hp > 0:
			body.contact()
		else:
			body.disable()
		
func _ready():
	timer.connect("timeout", self, "on_player_timer_timerout")
	area.connect("body_enter", self, "on_player_body_enter")
	game_manager.current_scene.get_node("Camera2D").start_camera(self)
	hp = game_manager.health

	update_healthbar()
	set_fixed_process(true)

