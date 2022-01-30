extends Node

enum Power { NONE, STOMP }
var current_power = Power.NONE

signal energy_update

export var max_energy = 100.0
export var energy_hz = 30.0
export var stomp_cost = 30.0

var energy = max_energy

func _process(delta):
	energy = clamp(energy + energy_hz * delta, 0, max_energy)
	emit_signal("energy_update", energy / max_energy)

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
		if energy >= stomp_cost:
			$Stomp.run()
			energy -= stomp_cost
		
	
