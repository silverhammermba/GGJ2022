extends CanvasLayer

signal play_again
signal reset_power
signal activate_stomp

func _ready():
	reset()

func _on_PlayAgainButton_pressed():
	reset()
	emit_signal("play_again")
	
func _on_NoPowerButton_pressed():
	emit_signal("reset_power")

func _on_StompButton_pressed():
	emit_signal("activate_stomp")

func update_pawns_remaining(count):
	$PawnsRemainingContainer/Counter.text = str(count)

func show_win_condition():
	$WinLabel.show()
	$PlayAgainButton.show()
	
func show_lose_condition():
	$LoseLabel.show()
	$PlayAgainButton.show()
	
func reset():
	$LoseLabel.hide()
	$WinLabel.hide()
	$PlayAgainButton.hide()
