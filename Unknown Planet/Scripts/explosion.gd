extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var anim = get_node("AnimationPlayer")
onready var sample_player = get_node("SamplePlayer2D")
export var is_boss = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	sample_player.play("explode")
	anim.connect("finished", self, "on_small_explosion_anim_finished")

func on_small_explosion_anim_finished():
	if is_boss:
		game_manager.goto_scene("res://Scenes/"+game_manager.scenes[22]+".tscn")
	else:
		queue_free()