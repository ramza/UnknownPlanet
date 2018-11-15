extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var start_pos

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	start_pos = get_global_pos()
	set_process(true)
	
func _process(delta):
	update()
	
func _draw():
	draw_line(Vector2(0,0), Vector2(0,start_pos.y-get_global_pos().y), Color(255,255,255,1),1);
