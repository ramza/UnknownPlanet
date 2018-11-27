extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var shop_panel = get_node("ShopPanel")
onready var selector = shop_panel.get_node("selected")
onready var iteminfo = shop_panel.get_node("ItemInfo")
onready var timer = get_node("Timer")
onready var sample_player = get_node("SamplePlayer2D")

var index = 0
var can_input = true
var check_out = false

var finished = false

var infos = [
	"Increase Health $10",
	"Max charge $20",
	"Rapid Fire $20",
]
var start_pos

func reset_infos():
	infos = [
	"Increase Health $10",
	"Max charge $20",
	"Rapid Fire $20",
    ]

func ready_infos():
	if game_manager.hp_upgrade:
		if game_manager.hp_upgrade2:
			infos[0] = "Already purchased"
		else:
			infos[0] = "Increase Health 2 $10"
	if game_manager.gun_upgrade:
		if game_manager.gun_upgrade2:
			infos[1] = "Already purchased"
		else:
			infos[1] = "Max charge 2 $20"
	if game_manager.firerate_upgrade:
		if game_manager.firerate_upgrade2:
			infos[2] = "Already purchased"
		else:
			infos[2] = "Rapid Fire 2 $20"
			
	iteminfo.set_text("")
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	shop_panel.hide()
	connect("body_enter", self, "on_shop_body_enter")
	timer.connect("timeout", self, "on_shop_timer_timeout")
	iteminfo.set_text("")
	start_pos = selector.get_pos()

func on_shop_body_enter(body):
	if body.is_in_group("player"):
		ready_infos()
		body.disable()
		shop_panel.show()
		game_manager.HUD.can_pause = false
		set_process(true)
		
func on_shop_timer_timeout():
	timer.stop()
	can_input = true
	if finished:
		game_manager.player.enable()
		finished = false
		game_manager.HUD.can_pause = true
		
func _process(delta):
	var right = Input.is_action_pressed("move_right") and can_input
	var left = Input.is_action_pressed("move_left") and can_input
	var cancel = Input.is_action_pressed("ui_cancel")
	
	if cancel:
		close_shop()
		
	var select = (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("start")) and can_input
	
	if right:
		index += 1
	if left:
		index -= 1
	
	if index > infos.size()-1:
		index = infos.size()-1
	elif index < 0:
		index = 0
	
	if left or right:
		sample_player.play("select")
		can_input = false
		check_out = false
		timer.start()
		selector.set_pos(Vector2(start_pos.x + (index*17), start_pos.y))
	
	if select:
		if check_out:
			do_purchase()
			
		timer.start()
		can_input = false
		iteminfo.set_text(infos[index])
		check_out = true

func do_purchase():
	check_out = false
	if index == 0 and (!game_manager.hp_upgrade2):
		if game_manager.cash_money >= 10:
			game_manager.cash_money -= 10
			game_manager.player.max_hp += 1
			sample_player.play("coin")
			if game_manager.hp_upgrade:
				game_manager.hp_upgrade2 = true
			else:
				game_manager.hp_upgrade = true
			close_shop()
		else:
			infos[0] = "Not enough $"

	elif index == 1 and !game_manager.gun_upgrade2:
		if game_manager.cash_money >= 20:
			game_manager.cash_money -= 20
			sample_player.play("coin")
			var rate = 0.0
			if game_manager.gun_upgrade:
				game_manager.gun_upgrade2 = true
				rate = 0.25
			else:
				game_manager.gun_upgrade = true
				rate = 0.5
			game_manager.player.get_node("LaserGun").energy_replenish_delay = rate
			close_shop()
		else:
			infos[1] = "Not enough $"
	
	elif index == 2 and !game_manager.firerate_upgrade2:
		if game_manager.cash_money >= 20:
			game_manager.cash_money -= 20
			var rate = 0.0
			sample_player.play("coin")
			if game_manager.firerate_upgrade:
				game_manager.firerate_upgrade2 = true
				rate = 0.1
			else:
				game_manager.firerate_upgrade = true
				rate = 0.15
			game_manager.player.get_node("LaserGun").firerate = rate
			close_shop()
		else:
			infos[2] = "Not enough $"
	
	
func close_shop():
	shop_panel.hide()
	game_manager.HUD.update_cash()
	set_process(false)
	game_manager.player.update_healthbar()
	finished = true
	timer.start()
	iteminfo.set_text(" ")
	reset_infos()
	
		