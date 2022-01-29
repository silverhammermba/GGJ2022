extends Node2D

export var strength = 150
export var strength_force_scale = 1

enum RunState { INACTIVE, ACTIVE, CONCLUDED }
var run_state = RunState.INACTIVE

func _ready():
	deactivate()
	get_node("CollisionShape2D").disabled = true

func _process(_delta):
	position = get_viewport().get_mouse_position()
	
func _physics_process(_delta):
	if run_state == RunState.ACTIVE:
		get_node("CollisionShape2D").disabled = false
		run_state = RunState.CONCLUDED
	elif run_state == RunState.CONCLUDED:
		get_node("CollisionShape2D").disabled = true
		run_state = RunState.INACTIVE

func _on_Stomp_body_entered(body):
	if "faction" in body:
		body.damage(strength, strength * strength_force_scale, global_position)

func activate():
	show()
	set_process(true)
	
func deactivate():
	hide()
	set_process(false)
	
func run():
	run_state = RunState.ACTIVE
