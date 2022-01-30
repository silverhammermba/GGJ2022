extends Node

var maximum_allowable_deaths
export var max_lost_percentage = 0.25

func _ready():
	maximum_allowable_deaths = $Battlefield.army_size * 2 * max_lost_percentage
	reset()

func _on_HUD_play_again():
	reset()

func _on_HUD_reset_power():
	$Powers.set_active_power($Powers.Power.NONE)

func _on_HUD_activate_stomp():
	$Powers.set_active_power($Powers.Power.STOMP)
	
func _on_HUD_activate_boulder():
	$Powers.set_active_power($Powers.Power.BOULDER)

func _on_Battlefield_pawns_remaining(count):
	var deaths = $Battlefield.army_size * 2 - count
	$HUD.update_pawns_remaining(deaths)
	
	if deaths > maximum_allowable_deaths:
		lose_condition()

func reset():
	$HUD.update_pawns_remaining(0)
	$Powers.reset()
	$Battlefield.reset()

func lose_condition():
	$Battlefield.halt_pawns()
	$HUD.show_lose_condition()

