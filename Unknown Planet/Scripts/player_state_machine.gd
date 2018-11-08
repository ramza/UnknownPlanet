extends Node

onready var anim = get_node("AnimationPlayer")

var STATES = {
	"IDLE":0,
	"WALK":1,
	"HURT":3,
	"JUMP":4,
	"DEAD":5,
	"SHOOT":6,
	"LADDER":7,
	"LADDER_HOLD":8,
	"FALL":9,
}

var state = STATES.IDLE
var prev_state

func do_animation():
	var current_anim = ""
	if state == STATES.IDLE:
		current_anim = "idle"
	if state == STATES.WALK:
		current_anim = "walk"
	if state == STATES.JUMP:
		current_anim = "jump"
	if state == STATES.HURT:
		current_anim = "hurt"
	if state == STATES.DEAD:
		current_anim = "dead"
	if state == STATES.SHOOT:
		current_anim = "shoot"
	if state == STATES.LADDER:
		current_anim = "ladder"
	if state == STATES.LADDER_HOLD:
		current_anim = "ladder_hold"
	if state == STATES.FALL:
		current_anim = "fall"
		
	if !anim.is_playing() || state != prev_state:
		anim.play(current_anim)

	prev_state = state
	
func shoot():
	state = STATES.SHOOT
	
func idle():
	state = STATES.IDLE
	
func walk():
	state = STATES.WALK
	
func ladder():
	state = STATES.LADDER
	
func ladder_hold():
	state = STATES.LADDER_HOLD

func hurt():
	state = STATES.HURT

func fall():
	state = STATES.FALL

func jump():
	state = STATES.JUMP
	
func dead():
	state = STATES.DEAD

func on_player_state_machine_anim_finished():
	if state == STATES.DEAD:
		get_parent().set_fixed_process(false)

func _ready():
	# Called every time the node is added to the scene.
	anim.connect("finished", self, "on_player_state_machine_anim_finished")
