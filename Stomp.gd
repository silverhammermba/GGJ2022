extends Node2D

signal stomped(position)

export var strength = 150.0
export var strength_force_scale = 1.0
export var delay = 1.0
export var min_alpha = 0.1
export var min_scale = 0.5
export var demoralize_effect = 20

var sprite: Sprite
var timer: Timer
var kill_coll: CollisionShape2D
var demoralize_coll: CollisionShape2D
var max_sprite_scale: Vector2
var audio: AudioStreamPlayer2D

enum RunState { INACTIVE, PREPARING, ACTIVE, CONCLUDED }
var run_state = RunState.INACTIVE
const ready_color = Color(0, 0, 0)
const unready_color = Color(1, 0, 0)
var color: Color

func _ready():
	audio = $AudioStreamPlayer2D
	demoralize_coll = $DemoralizeArea/CollisionShape2D
	kill_coll = $KillArea/CollisionShape2D
	sprite = $Sprite
	max_sprite_scale = sprite.scale
	timer = $Timer
	timer.one_shot = true
	deactivate()
	demoralize_coll.disabled = true
	kill_coll.disabled = true
	color = ready_color

func _process(_delta):
	position = get_viewport().get_mouse_position()
	if run_state == RunState.PREPARING:
		var animation_progress = 1 - timer.time_left / delay
		
		sprite.modulate = Color(ready_color.r, ready_color.g, ready_color.b, lerp(min_alpha, 1, animation_progress))
		sprite.scale = max_sprite_scale * lerp(1, min_scale, animation_progress)
	elif run_state == RunState.INACTIVE:
		sprite.modulate = Color(color.r, color.g, color.b, min_alpha)
	
func _physics_process(_delta):
	if run_state == RunState.ACTIVE:
		sprite.modulate = Color(color.r, color.g, color.b, 1)
		demoralize_coll.disabled = false
		kill_coll.disabled = false
		emit_signal("stomped", position)
		run_state = RunState.CONCLUDED
		audio.stop()
		audio.play()
	elif run_state == RunState.CONCLUDED:
		demoralize_coll.disabled = true
		kill_coll.disabled = true
		run_state = RunState.INACTIVE
		sprite.modulate = Color(color.r, color.g, color.b, min_alpha)
		sprite.scale = max_sprite_scale

func activate():
	sprite.modulate = Color(color.r, color.g, color.b, min_alpha)
	sprite.scale = max_sprite_scale
	show()
	set_process(true)
	
func deactivate():
	hide()
	set_process(false)
	
func show_ready(ready):
	if ready:
		color = ready_color
	else:
		color = unready_color
	
func run():
	if run_state == RunState.INACTIVE:
		run_state = RunState.PREPARING
		timer.start(delay)

func _on_Timer_timeout():
	run_state = RunState.ACTIVE

func _on_KillArea_body_entered(body):
	if "faction" in body:
		body.stun()
		body.damage(strength, strength * strength_force_scale, global_position)

func _on_DemoralizeArea_body_entered(body):
	if "faction" in body:
		body.terrify(demoralize_effect, demoralize_effect * strength_force_scale, global_position)
