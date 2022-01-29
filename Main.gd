extends Node

func _on_Controls_reset_power():
	$Powers.set_active_power($Powers.Power.NONE)

func _on_Controls_activate_stomp():
	$Powers.set_active_power($Powers.Power.STOMP)
