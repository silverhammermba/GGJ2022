extends Node

var maximum_allowable_deaths

func _ready():
	maximum_allowable_deaths = $Battlefield.army_size / 2  # Tweak as needed
	reset()

func _on_HUD_play_again():
	reset()

func _on_HUD_reset_power():
	$Powers.set_active_power($Powers.Power.NONE)

func _on_HUD_activate_stomp():
	$Powers.set_active_power($Powers.Power.STOMP)

func _on_Battlefield_pawns_remaining(count):
	$HUD.update_pawns_remaining(count)
	
	if $Battlefield.army_size * 2 - count > maximum_allowable_deaths:
		lose_condition()

func reset():
	$HUD.update_pawns_remaining($Battlefield.army_size * 2)
	$Powers.reset()
	$Battlefield.reset()

func lose_condition():
	$Battlefield.halt_pawns()
	$HUD.show_lose_condition()
