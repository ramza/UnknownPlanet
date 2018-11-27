extends Node2D

var messeges = [
	"We got a signal from deep space.",
	"The pilot said we shouldn't go.",
	"He had a bad feeling.",
	"But the Doc insisted, saying it was our duty.",
]

onready var anim = get_node("AnimationPlayer")
onready var label = get_node("Label")
onready var black_screen = get_node("BlackScreen")
onready var timer = get_node("Timer")

var index = 1

var input_timer = 0
var start_delay = 2
var can_input = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer.connect("timeout", self, "on_story_timer_timeout")
	anim.connect("finished", self, "on_story_anim_finished")
	timer.start()
	set_process(true)
	
func on_story_anim_finished():
	game_manager.goto_scene("res://Scenes/"+game_manager.scenes[1]+".tscn")

func _process(delta):
	input_timer += delta
	if input_timer > start_delay:
		can_input = true
	if can_input and (Input.is_action_pressed("fire") or Input.is_action_pressed("start")):
		on_story_anim_finished()
	pass
	
func on_story_timer_timeout():
	if index >= messeges.size():
		timer.stop()
		anim.play("Planet")
		label.set_hidden(true)
	else:
		label.set_text(messeges[index]);
		index+=1
