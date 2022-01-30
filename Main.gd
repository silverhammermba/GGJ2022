extends Node

var maximum_allowable_deaths
export var max_lost_percentage = 0.25
export var win_duration = 60.0
export var win_screen_delay = 2

var win_timer: Timer

export var min_volume = -40.0
export var max_volume = 0.0
export var max_attacks_hz = 40.0
export var average_volume_over_ms = 1500.0

var game_over = false
var ambience_volume = min_volume

var ambience: AudioStreamPlayer
var attacks = []

func _ready():
	win_timer = $WinTimer
	ambience = $AudioStreamPlayer
	ambience.volume_db = min_volume
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
	attacks = []
	ambience_volume = min_volume
	game_over = false
	$HUD.update_pawns_remaining(0)
	$Powers.reset()
	$Battlefield.reset()
	win_timer.start(win_duration)
	
	for node in $Battlefield.get_children():
		if "faction" in node:
			node.connect("attack", self, "_on_Pawn_attack")
	
func _process(_delta):
	# calculate attacks per second
	var i = attacks.size() - 1
	var now = OS.get_ticks_msec()
	var attacks_hz = 0.0
	while i >= 0 and now - attacks[i] <= average_volume_over_ms:
		attacks_hz += 1
		i -= 1
		
	attacks_hz *= 1000.0 / average_volume_over_ms
	
	ambience.volume_db = lerp(min_volume, max_volume, clamp(attacks_hz / max_attacks_hz, 0, 1))

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

func _on_Pawn_attack():
	attacks.append(OS.get_ticks_msec())
