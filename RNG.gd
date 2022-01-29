extends Node

var gen = RandomNumberGenerator.new()

func _ready():
	gen.randomize()

func rand_vec2(magnitude=1):
	var angle = gen.randf_range(0, 2 * PI)
	return Vector2(cos(angle), sin(angle)) * magnitude
