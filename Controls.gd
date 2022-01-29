extends CanvasLayer

signal reset_power
signal activate_stomp

func _on_ResetButton_pressed():
	emit_signal("reset_power")

func _on_StompButton_pressed():
	emit_signal("activate_stomp")
