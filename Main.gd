extends Node

var maximum_allowable_deaths
export var max_lost_percentage = 0.25
export var win_duration = 60.0
export var win_screen_delay = 2

var win_timer: Timer

export var min_shout_volume = -40.0
export var max_shout_volume = 0.0
export var min_sword1_volume = -80.0
export var max_sword1_volume = 0.0
export var min_sword2_volume = -80.0
export var max_sword2_volume = 0.0
export var max_attacks_hz = 40.0
export var average_volume_over_ms = 1500.0

var game_over = false
var won = false

var shout_audio: AudioStreamPlayer
var sword_audio1: AudioStreamPlayer
var sword_audio2: AudioStreamPlayer
var attacks = []

func _ready():
	win_timer = $WinTimer
	shout_audio = $ShoutAudio
	sword_audio1 = $SwordAudio1
	sword_audio2 = $SwordAudio2
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
	shout_audio.volume_db = min_shout_volume
	sword_audio1.volume_db = min_sword1_volume
	sword_audio2.volume_db = min_sword2_volume
	game_over = false
	won = false
	$HUD.update_pawns_remaining(0)
	$Powers.reset()
	$Battlefield.reset()
	win_timer.start(win_duration)
	
	for node in $Battlefield.get_children():
		if "faction" in node:
			node.connect("attack", self, "_on_Pawn_attack")
	
func _process(delta):
	if won:
		shout_audio.volume_db -= 30 * delta
		sword_audio1.volume_db -= 30 * delta
		sword_audio2.volume_db -= 30 * delta
	else:
		# calculate attacks per second
		var i = attacks.size() - 1
		var now = OS.get_ticks_msec()
		var attacks_hz = 0.0
		while i >= 0 and now - attacks[i] <= average_volume_over_ms:
			attacks_hz += 1
			i -= 1
			
		attacks_hz *= 1000.0 / average_volume_over_ms
		var scale = clamp(attacks_hz / max_attacks_hz, 0, 1)
		
		var min_sword1 = min_sword1_volume
		var min_sword2 = min_sword2_volume
		if attacks_hz == 0:
			min_sword1 = -80
			min_sword2 = -80
		
		shout_audio.volume_db = lerp(min_shout_volume, max_shout_volume, scale)
		sword_audio1.volume_db = lerp(min_sword1, max_sword1_volume, scale)
		sword_audio2.volume_db = lerp(min_sword2, max_sword2_volume, scale)

func lose_condition():
	if not game_over:
		game_over = true
		$HUD.show_lose_condition()
	
func win_condition():
	if not game_over:
		game_over = true
		won = true
		$Battlefield.evacuate_pawns()
		$WinConditionTimer.start(win_screen_delay)
	
func _on_WinConditionTimer_timeout():
	$HUD.show_win_condition()
	$WinConditionTimer.stop()

func _on_WinTimer_timeout():
	win_condition()

func _on_Pawn_attack():
	attacks.append(OS.get_ticks_msec())
