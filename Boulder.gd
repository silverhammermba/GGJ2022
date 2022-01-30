extends Node2D

# sprite credit:
# This work, made by Viktor Hahn (Viktor.Hahn@web.de), is licensed under the Creative Commons Attribution 4.0 International License. http://creativecommons.org/licenses/by/4.0/

export var damage = 60.0
export var damage_force_scale = 5.0
export var demoralize_effect = 40.0
export var demoralize_force_scale = 5.0
export var speed_anim_ratio = 1.0

var kill_coll: CollisionShape2D
var demoralize_coll: CollisionShape2D
var sprite: AnimatedSprite
var splat_sound: AudioStreamPlayer2D

var roll_hz = Vector2()

enum RunState { INACTIVE, PREPARING, ACTIVE, CONCLUDED }
var run_state = RunState.INACTIVE

func _ready():
	demoralize_coll = $DemoralizeArea/CollisionShape2D
	kill_coll = $KillArea/CollisionShape2D
	sprite = $AnimatedSprite
	splat_sound = $SplatPlayer
	
func roll(direction, speed):
	# scale effect by speed
	damage = damage * speed
	demoralize_effect = demoralize_effect * speed
	# set movement and appearance to match roll
	rotate(direction.angle())
	roll_hz = direction.normalized() * speed
	sprite.speed_scale = speed * speed_anim_ratio
	
func _physics_process(delta):
	global_position += roll_hz * delta
	
func _on_KillArea_body_entered(body):
	if "faction" in body:
		body.stun()
		body.damage(damage, damage * damage_force_scale, global_position)
		splat_sound.play()

func _on_DemoralizeArea_body_entered(body):
	if "faction" in body:
		body.terrify(demoralize_effect, demoralize_effect * demoralize_force_scale, global_position)
