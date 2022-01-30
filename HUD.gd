extends CanvasLayer

signal play_again
signal reset_power
signal activate_stomp
signal activate_boulder

var energy_max_size
var energy_rect: ColorRect

func _ready():
	energy_rect = $ManaRect
	energy_max_size = energy_rect.rect_size.x
	reset()

func _on_PlayAgainButton_pressed():
	reset()
	emit_signal("play_again")
	
func _on_NoPowerButton_pressed():
	emit_signal("reset_power")

func _on_StompButton_pressed():
	emit_signal("activate_stomp")
	
func _on_BoulderButton_pressed():
	emit_signal("activate_boulder")
	
func _on_Powers_energy_update(energy):
	energy_rect.set_size(Vector2(energy_max_size * energy, energy_rect.rect_size.y))

func update_pawns_remaining(count):
	$PawnsRemainingContainer/Counter.text = "Deaths: " + str(count)

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
