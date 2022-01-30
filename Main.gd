extends Node

var maximum_allowable_deaths
export var max_lost_percentage = 0.25
export var win_duration = 60.0
export var win_screen_delay = 2

var win_timer: Timer

var game_over = false

func _ready():
	win_timer = $WinTimer
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
	game_over = false
	$HUD.update_pawns_remaining(0)
	$Powers.reset()
	$Battlefield.reset()
	win_timer.start(win_duration)
	

func lose_condition():
	if not game_over:
		game_over = true
		$HUD.show_lose_condition()
	
func win_condition():
	if not game_over:
		game_over = true
		$Battlefield.evacuate_pawns()
		$WinConditionTimer.start(win_screen_delay)
	
func _on_WinConditionTimer_timeout():
	$HUD.show_win_condition()
	$WinConditionTimer.stop()

func _on_WinTimer_timeout():
	win_condition()
