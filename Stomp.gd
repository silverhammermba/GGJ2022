extends Node2D

export var strength = 150.0
export var strength_force_scale = 1.0
export var delay = 1.0
export var min_alpha = 0.1
export var demoralize_effect = 20

var sprite: Sprite
var timer: Timer
var kill_coll: CollisionShape2D
var demoralize_coll: CollisionShape2D

enum RunState { INACTIVE, PREPARING, ACTIVE, CONCLUDED }
var run_state = RunState.INACTIVE

func _ready():
	demoralize_coll = $DemoralizeArea/CollisionShape2D
	kill_coll = $KillArea/CollisionShape2D
	sprite = $Sprite
	timer = $Timer
	timer.one_shot = true
	deactivate()
	demoralize_coll.disabled = true
	kill_coll.disabled = true

func _process(_delta):
	position = get_viewport().get_mouse_position()
	if run_state == RunState.PREPARING:
		sprite.modulate = Color(0, 0, 0, (min_alpha - 1) / delay * timer.time_left + 1)
	
func _physics_process(_delta):
	if run_state == RunState.ACTIVE:
		sprite.modulate = Color(0, 0, 0, 1)
		demoralize_coll.disabled = false
		kill_coll.disabled = false
		run_state = RunState.CONCLUDED
	elif run_state == RunState.CONCLUDED:
		demoralize_coll.disabled = true
		kill_coll.disabled = true
		run_state = RunState.INACTIVE
		sprite.modulate = Color(0, 0, 0, min_alpha)

func activate():
	sprite.modulate = Color(0, 0, 0, min_alpha)
	show()
	set_process(true)
	
func deactivate():
	hide()
	set_process(false)
	
func run():
	if run_state == RunState.INACTIVE:
		run_state = RunState.PREPARING
		timer.start(delay)

func _on_Timer_timeout():
	run_state = RunState.ACTIVE

func _on_KillArea_body_entered(body):
	if "faction" in body:
		body.damage(strength, strength * strength_force_scale, global_position)

func _on_DemoralizeArea_body_entered(body):
	if "faction" in body:
		body.terrify(demoralize_effect, demoralize_effect * strength_force_scale, global_position)
