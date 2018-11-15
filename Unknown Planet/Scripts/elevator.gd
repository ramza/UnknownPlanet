extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var scene_num = 1
onready var anim = get_node("AnimationPlayer")
onready var timer = get_node("Timer")
var active = false

export var go_down = true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization he
	anim.play("idle")
	connect("body_enter", self, "on_lift_body_enter")
	timer.connect("timeout", self, "on_timer_timeout")
	
func on_timer_timeout():
	game_manager.goto_scene("res://Scenes/"+game_manager.scenes[scene_num]+".tscn")
		
	
func on_lift_body_enter(body):
	print("what up")
	if !active and body.is_in_group("player"):
		active = true
		body.disable()
		body.set_pos(get_pos())
		timer.start()
		if go_down:
			anim.play("go_down")
			game_manager.spawnpoint = 1
		else:
			anim.play("go_up")
			game_manager.spawnpoint = 2
