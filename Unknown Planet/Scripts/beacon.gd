extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var scene = 0
onready var anim = get_node("AnimationPlayer")
onready var area = get_node("Area2D")
onready var timer = get_node("Timer")
onready var ring_timer = get_node("ring_timer")
onready var sample_player = get_node("SamplePlayer2D")
export var spawnpoint = 1

export var blue_beacon = false

func _ready():
	if blue_beacon and !game_manager.killed_worm:
		queue_free()
	# Called every time the node is added to the scene.
	# Initialization here
	area.connect("body_enter", self, "on_beacon_area_body_enter")
	area.connect("body_exit", self, "on_beacon_area_body_exit")
	timer.connect("timeout", self, "on_beacon_timer_timerout")
	ring_timer.connect("timeout", self, "on_ring_timer_timeout")
	
	anim.play("idle")

func on_beacon_timer_timerout():
	game_manager.save_player_stats()
	game_manager.current_scene_index = scene
	game_manager.spawnpoint = spawnpoint
	game_manager.goto_scene("res://Scenes/"+game_manager.scenes[scene]+".tscn")

func on_ring_timer_timeout():
	sample_player.play("ring")

func on_beacon_area_body_enter(body):
	if body.is_in_group("player"):
		timer.start()
		anim.play("flash")
		ring_timer.start()
		sample_player.play("ring")
	
		
func on_beacon_area_body_exit(body):
	if body.is_in_group("player"):
		timer.stop()
		ring_timer.stop()
		anim.play("idle")