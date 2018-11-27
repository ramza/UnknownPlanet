extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var redshot = preload("res://Scenes/red_shot.tscn")
onready var sprite = get_node("Sprite")
onready var state_machine = get_node("EnemyStateMachine")
onready var timer = get_node("Timer")
onready var shoot_timer = get_node("ShootTimer")
onready var area2d = get_node("Area2D")
onready var sample_player = get_node("SamplePlayer2D")
onready var muzzle = get_node("Muzzle")

var coin = preload("res://Scenes/coin.tscn")
var ammo = preload("res://Scenes/ammopack.tscn")

export var invincible = false
export var damage = 1
var explosion
var hp = 3
var max_hp = 3
var can_act = true

const GRAVITY = 500.0

var target

var velocity = Vector2(0,0)

func load_explosion():
	explosion = load("res://Scenes/small_explosion.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	initialize_enemy()
	pass
	
func on_enemy_area_body_enter(body):
	if body.is_in_group("player"):
		shoot_timer.start()
		target = body
		
func on_enemy_shoot_timer_timeout():
	var shot = redshot.instance()
	shot.velocity = (get_pos() - target.get_pos()).normalized()*-1
	shot.set_global_pos(muzzle.get_global_pos())
	print("making a shot")
	game_manager.current_scene.add_child(shot)
	
func initialize_enemy():
	load_explosion()
	shoot_timer.connect("timeout", self, "on_enemy_shoot_timer_timeout")
	timer.connect("timeout", self, "on_enemy_timer_timeout")
	area2d.connect("body_enter", self, "on_enemy_area_body_enter")
	area2d.connect("body_exit", self, "on_planet_body_exit")
	state_machine.idle()
	set_fixed_process(true)
	
func on_planet_body_exit(body):
	if body.is_in_group("player"):
		shoot_timer.stop()
		
func drop_item(item):
	var i = item.instance()
	i.set_global_pos(get_global_pos())
	game_manager.current_scene.add_child(i)
	
func movement(delta):
	var force = Vector2(0,GRAVITY)
	
	velocity += force * delta
	var motion = velocity*delta
	motion = move(motion)
	
func _fixed_process(delta):
	state_machine.do_animation()
	if can_act:
		movement(delta)
	
func on_enemy_timer_timeout():
	timer.stop()
	if state_machine.state == state_machine.STATES.HURT:
		state_machine.idle()
	can_act = true
		
func contact():
	state_machine.hurt()
	timer.start()
	
func disable():
	_fixed_process(false)
	can_act = false
	get_node("CollisionShape2D").set_trigger(true)
	
func take_damage(dmg):
	hp -= dmg 
	sample_player.play("hurt")
	if hp <= 0:
		death()
	else:
		state_machine.hurt()
		timer.start()
		
func death():
	var e = explosion.instance()
	game_manager.current_scene.add_child(e)
	e.set_global_pos(get_global_pos())
	
	var r = rand_range(0,10)
	if r < 3:
		drop_item(coin)
	elif r < 5:
		drop_item(ammo)
	
	queue_free()

