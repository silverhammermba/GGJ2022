extends Node2D

# sprite credit:
# This work, made by Viktor Hahn (Viktor.Hahn@web.de), is licensed under the Creative Commons Attribution 4.0 International License. http://creativecommons.org/licenses/by/4.0/

export var damage = 60.0
export var damage_force_scale = 5.0
export var demoralize_effect = 40
export var demoralize_force_scale = 5.0
export var speed = 10

var kill_coll: CollisionShape2D
var demoralize_coll: CollisionShape2D

var direction = Vector2()

enum RunState { INACTIVE, PREPARING, ACTIVE, CONCLUDED }
var run_state = RunState.INACTIVE

func _ready():
	demoralize_coll = $DemoralizeArea/CollisionShape2D
	kill_coll = $KillArea/CollisionShape2D
	
func _physics_process(delta):
	global_position += direction * speed * delta
	
func _on_KillArea_body_entered(body):
	if "faction" in body:
		body.damage(damage, damage * damage_force_scale, global_position)

func _on_DemoralizeArea_body_entered(body):
	if "faction" in body:
		body.terrify(demoralize_effect, demoralize_effect * demoralize_force_scale, global_position)
