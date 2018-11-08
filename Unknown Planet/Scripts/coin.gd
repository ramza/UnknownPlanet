extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var gold_burst = preload("res://Scenes/gold_burst.tscn")
var pickup_type = "coin"
var amount = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	setup()
	set_fixed_process(true)
	
func setup():
	connect("body_enter", self, "on_coin_pickup_body_enter")
	
func do_fx(player):
	game_manager.cash_money+=1
	game_manager.HUD.update_cash()
	pass

func on_coin_pickup_body_enter(body):
	if body.is_in_group("player"):
		do_fx(body)
		var gb = gold_burst.instance()
		gb.set_global_pos(get_global_pos())
		game_manager.current_scene.add_child(gb)
		queue_free()

