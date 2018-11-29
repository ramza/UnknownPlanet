extends KinematicBody2D

var can_act = true
var claw_attack = preload("res://Scenes/claw_attack.tscn")
var fireball = preload("res://Scenes/fireball.tscn")
var explosion = preload("res://Scenes/boss_explosion.tscn")
var coin = preload("res://Scenes/coin.tscn")
var ammo = preload("res://Scenes/ammopack.tscn")
export var hp = 5
export var damage = 1
var player 

var facing_dir = 1
onready var state_machine = get_node("EnemyStateMachine")
onready var sprite = get_node("Sprite")
onready var timer = get_node("Timer")
onready var rightcast = get_node("RightCast")
onready var rightcast1 = get_node("RightCast1")
onready var leftcast = get_node("LeftCast")
onready var leftcast1 = get_node("LeftCast1")
onready var left_footcast = get_node("LeftFootCast")
onready var right_footcast = get_node("RightFootCast")
onready var sample_plyr = get_node("SamplePlayer2D")
onready var rightcastupper = get_node("RightCastUpper")
onready var leftcastupper = get_node("LeftCastUpper")
onready var attack_timer = get_node("AttackTimer")
onready var attack_target = get_node("Target")
onready var spell_target = get_node("SpellTarget")

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

var super_walk_l
var super_walk_r

var velocity = Vector2()
var on_air_time = 100
var jumping = false
export var speed = 1
var prev_jump_pressed = false

export var overrun = false
var can_attack = true
var walk_timer = 0
var walk_delay = 1.5

var spell_timer = 0
var spell_delay = 2

func attack():
	var attack = claw_attack.instance()
	attack.set_pos(attack_target.get_pos())
	attack.set_scale(Vector2(-facing_dir,1))
	add_child(attack)
	can_act = false
	attack_timer.start()
	state_machine.attack()
	
func do_spell():
	var fball = fireball.instance()
	fball.speed *= spell_target.get_pos().x/-40
	fball.set_pos(spell_target.get_pos())
	add_child(fball)
	can_act = false
	attack_timer.start()
	state_machine.spell()

func take_damage(damage):
	if player == null:
		player = get_tree().get_root().get_child(1).get_node("player")

	if facing_dir == -1 and player.get_pos().x > get_pos().x:
		super_walk_r
	elif facing_dir == 1 and player.get_pos().x < get_pos().x:
		super_walk_l
		
	hp -= damage
	sample_plyr.play("hurt")
	if (!overrun):
		timer.start()

	if hp <= 0:
		death()
		
func drop_item(item):
	var i = item.instance()
	i.set_global_pos(get_global_pos())
	game_manager.current_scene.add_child(i)

func death():
	var new_explosion = explosion.instance()
	new_explosion.set_pos(self.get_pos())
	get_parent().add_child(new_explosion)
	game_manager.player.disable()
	
	queue_free()
	
func walk_right():
	if super_walk_r:
		return true
	if rightcast.is_colliding():
		var body = rightcast.get_collider()
		#print("hit a " + body.get_name())
		if body != null and body.is_in_group("player"):
			return true
	if rightcast1.is_colliding():
		var body = rightcast1.get_collider()
		#print("hit a " + body.get_name())
		if body != null and body.is_in_group("player"):
			return true
	return false
	
func walk_left():
	if super_walk_l:
		return true
	if leftcast.is_colliding():
		var body = leftcast.get_collider()
		if body != null and body.is_in_group("player"):
			return true
	if leftcast1.is_colliding():

		var body = leftcast1.get_collider()
		if body != null and body.is_in_group("player"):
			return true
	return false
	
func movement(delta):
	walk_timer += delta
	# Create forces
	
	if can_attack and abs(player.get_pos().x - get_pos().x) < 50:
		if get_scale().x == -1 and leftcast.is_colliding() and leftcast.get_collider().is_in_group("player"):
			pass
		elif get_scale().x == 1 and rightcast.is_colliding() and rightcast.get_collider().is_in_group("player"):
			pass
		else:
			attack()
			can_attack = false
			attack_timer.start()
	
	var force = Vector2(0, GRAVITY)
	
	var walk_left = walk_left()
	var walk_right = walk_right()
	var jump = false
	
	var stop = true
	
	if ((walk_left) and can_act and left_footcast.is_colliding()  and !leftcastupper.is_colliding()):
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			facing_dir = -1
			stop = false
			state_machine.walk()
			sprite.set_scale(Vector2(1,1))
			attack_target.set_pos(Vector2(-40, attack_target.get_pos().y))
			spell_target.set_pos(Vector2(-40, 0))
			walk_timer=0
	elif ((walk_right) and can_act and right_footcast.is_colliding() and !rightcastupper.is_colliding()):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			#print("walk rigtht")
			force.x += WALK_FORCE
			facing_dir = 1
			stop = false
			state_machine.walk()
			sprite.set_scale(Vector2(-1,1))
			attack_target.set_pos(Vector2(40, attack_target.get_pos().y))
			spell_target.set_pos(Vector2(40, 0))
			walk_timer=0
	
	if (leftcastupper.is_colliding() and facing_dir == -1) or (rightcastupper.is_colliding() and facing_dir == 1):
		walk_timer = 100000
		stop = true
		
	if (stop and (!overrun and walk_timer > walk_delay)):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	if velocity.x == 0 and velocity.y == 0:
		if state_machine.state != state_machine.STATES.HURT and state_machine.state != state_machine.STATES.ATTACK and state_machine.state != state_machine.STATES.SPELL:
			state_machine.idle()
		

		spell_timer += delta
		if spell_timer > spell_delay and ( (facing_dir == -1 and player.get_pos().x < get_pos().x) or (facing_dir == 1 and player.get_pos().x > get_pos().x)):
			do_spell()
			spell_timer = 0
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

func _fixed_process(delta):
	if player == null:
		player = game_manager.current_scene.get_node("player")
	else:
		movement(delta)

func contact():
	pass
	
func disable():
	set_fixed_process(false)
	get_node("CollisionShape2D").set_trigger(true)
	state_machine.idle()
	can_act = false
	
func on_enemy_timer_timeout():
	timer.stop()
	can_act = true
	
func on_enemy_attack_timer_timeout():
	state_machine.idle()
	attack_timer.stop()
	can_attack = true
	
func on_body_enter(body):
	pass
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer.connect("timeout", self, "on_enemy_timer_timeout")
	attack_timer.connect("timeout", self, "on_enemy_attack_timer_timeout")
	state_machine.idle()

	set_fixed_process(true)

