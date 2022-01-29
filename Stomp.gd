extends Node2D

export var strength = 150.0
export var strength_force_scale = 1.0
export var delay = 1.0
export var min_alpha = 0.1

var sprite: Sprite
var timer: Timer

enum RunState { INACTIVE, PREPARING, ACTIVE, CONCLUDED }
var run_state = RunState.INACTIVE

func _ready():
	sprite = $Sprite
	timer = $Timer
	timer.one_shot = true
	deactivate()
	get_node("CollisionShape2D").disabled = true

func _process(_delta):
	position = get_viewport().get_mouse_position()
	if run_state == RunState.PREPARING:
		sprite.modulate = Color(0, 0, 0, (min_alpha - 1) / delay * timer.time_left + 1)
	
func _physics_process(_delta):
	if run_state == RunState.ACTIVE:
		sprite.modulate = Color(0, 0, 0, 1)
		get_node("CollisionShape2D").disabled = false
		run_state = RunState.CONCLUDED
	elif run_state == RunState.CONCLUDED:
		get_node("CollisionShape2D").disabled = true
		run_state = RunState.INACTIVE
		sprite.modulate = Color(0, 0, 0, min_alpha)

func _on_Stomp_body_entered(body):
	if "faction" in body:
		body.damage(strength, strength * strength_force_scale, global_position)

func activate():
	sprite.modulate = Color(0, 0, 0, min_alpha)
	show()
	set_process(true)
	
func deactivate():
	hide()
	set_process(false)
	
func run():
	run_state = RunState.PREPARING
	timer.start(delay)
	
func delay_finished():
	run_state = RunState.ACTIVE

func _on_Timer_timeout():
	delay_finished()
