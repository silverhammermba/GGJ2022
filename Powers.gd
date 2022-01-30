extends Node

enum Power { NONE, STOMP, BOULDER }
var current_power = Power.NONE

signal energy_update

export var max_energy = 100.0
export var energy_hz = 30.0
export var stomp_cost = 30.0
export var boulder_cost = 10.0

var boulder = preload("res://Boulder.tscn")
var drag_start

var energy = max_energy

func _process(delta):
	energy = clamp(energy + energy_hz * delta, 0, max_energy)
	emit_signal("energy_update", energy / max_energy)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		run(current_power, event)

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
	
func run(power, event):
	if power == Power.NONE:
		pass
	elif power == Power.STOMP and event.pressed:
		if energy >= stomp_cost:
			$Stomp.run()
			energy -= stomp_cost
	elif power == Power.BOULDER:
		if event.pressed:
			drag_start = event.global_position
		else:
			if energy >= boulder_cost:
				var node = boulder.instance()
				add_child(node)
				node.global_position = drag_start
				node.direction = drag_start.direction_to(event.global_position)
				node.rotate(node.direction.angle())
				energy -= boulder_cost
			
