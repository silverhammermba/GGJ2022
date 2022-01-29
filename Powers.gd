extends Node

enum Power { NONE, STOMP }
var current_power = Power.NONE

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			run(current_power)

func reset():
	set_active_power(Power.NONE)

func set_active_power(power):
	if power != current_power:
		deactivate(current_power)
		activate(power)
		current_power = power
			
func activate(power):
	if power == Power.NONE:
		pass
	elif power == Power.STOMP:
		$Stomp.activate()
	
func deactivate(power):
	if power == Power.NONE:
		pass
	elif power == Power.STOMP:
		$Stomp.deactivate()
	
func run(power):
	if power == Power.NONE:
		pass
	elif power == Power.STOMP:
		$Stomp.run()
	
