extends Node2D

export var strength = 150
export var strength_force_scale = 1


func _process(delta):
	position = get_viewport().get_mouse_position()

func _on_Stomp_body_entered(body):
	if "faction" in body:
		body.damage(strength, strength * strength_force_scale, global_position)
