extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var laser = preload("res://Scenes/laser.tscn")
var firerate = 0.20
onready var sample_player = get_node("SamplePlayer2D")

var can_fire
var timer = 0.0
var facing_dir = 1

var ammo = 20
var max_ammo = 25

var energy_timer = 0
var energy_replenish_delay = 1.5

var shooting = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	initialize_ammo()
	update_ammo()
	set_process(true)
	
func initialize_ammo():
	game_manager.current_scene.find_node("HUD").initialize_ammo(max_ammo)

func update_ammo():
	ammo = game_manager.ammo
	game_manager.current_scene.find_node("HUD").update_ammo(ammo)
		
func add_ammo(amount):
	ammo = game_manager.ammo
	ammo += amount
	if ammo > max_ammo:
		ammo = max_ammo
	game_manager.ammo = ammo
	update_ammo()
	
func _process(delta):
	timer += delta
	energy_timer += delta
	ammo = game_manager.ammo
	if energy_timer > energy_replenish_delay && !Input.is_action_pressed("fire"):
		energy_timer = 0
		ammo += 1
		if ammo > max_ammo:
			ammo = max_ammo
		game_manager.ammo = ammo
		update_ammo()
	
	facing_dir = get_parent().facing_dir
	
	if ( get_parent().can_act and timer > firerate):
		can_fire = true
		pass
		
	if !Input.is_action_pressed("fire"):
		shooting = false
		pass
		
	if can_fire && Input.is_action_pressed("fire") and ammo > 0:
		timer = 0
		ammo = game_manager.ammo
		energy_timer = 0
		can_fire = false
		shooting = true
		var new_laser = laser.instance()
		new_laser.velocity = Vector2(facing_dir, 0)
		get_tree().get_root().get_child(0).add_child(new_laser)
		new_laser.set_global_pos(get_global_pos())
		ammo -= 1;
		game_manager.ammo = ammo
		update_ammo()
		sample_player.play("laser")