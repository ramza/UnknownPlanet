extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var scene_index = 0
export var start_position = 1
onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")
var done = false

export var needs_keycard = false
export var needs_red_keycard = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	anim.play("down")
	connect("body_enter", self, "on_portal_body_enter")
	anim.connect("finished", self, "on_portal_anim_finished")
	timer.connect("timeout", self, "on_portal_timer_timeout")
	
func on_portal_timer_timeout():
	sample_player.play("open")

func on_portal_anim_finished():
	if done and game_manager.player.hp > 0:
		game_manager.goto_scene("res://Scenes/"+game_manager.scenes[scene_index]+".tscn")
		

func on_portal_body_enter(body):
	if body.is_in_group("player"):
		if needs_keycard and !game_manager.blue_card:
			return
		elif needs_red_keycard and !game_manager.red_card:
			return
		body.disable()
		timer.start()
		game_manager.save_player_stats()
		game_manager.spawnpoint = start_position
		anim.play("rise")
		game_manager.HUD.fade_out()
		done = true