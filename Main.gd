extends Node

func _ready():
	$HUD.update_pawns_remaining($Battlefield.army_size*2)

func _on_HUD_reset_power():
	$Powers.set_active_power($Powers.Power.NONE)

func _on_HUD_activate_stomp():
	$Powers.set_active_power($Powers.Power.STOMP)

func _on_Battlefield_pawns_remaining(count):
	$HUD.update_pawns_remaining(count)
