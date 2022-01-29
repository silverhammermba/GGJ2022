extends Node2D

const pawn_scene = preload("res://Pawn.tscn")

var field_size: Vector2
export var deploy_edge = 0
export var deploy_width = 100
export var army_size = 50

var trues = []
var falses = []

func _ready():
	field_size = get_viewport().get_visible_rect().size
	
	for i in range(army_size):
		trues.append(add_pawn(true))
		falses.append(add_pawn(false))
		
func _process(delta):
	var avg_true = Vector2()
	for i in range(army_size):
		var pawn = trues[i].get_ref()
		if pawn:
			avg_true += pawn.global_position

	avg_true /= army_size
	
	var avg_false = Vector2()
	for i in range(army_size):
		var pawn = falses[i].get_ref()
		if pawn:
			pawn.nemesis = avg_true
			avg_false += pawn.global_position

	avg_false /= army_size
	
	for i in range(army_size):
		var pawn = trues[i].get_ref()
		if pawn:
			pawn.nemesis = avg_false

func add_pawn(faction):
	var pawn = pawn_scene.instance()
	add_child(pawn)
	pawn.set_faction(faction)
	var edge = deploy_edge
	if faction:
		pawn.target_dir = Vector2(-1, 0)
		edge = field_size.x - (edge + deploy_width)
	else:
		pawn.target_dir = Vector2(1, 0)
	
	pawn.global_position = Vector2(RNG.gen.randf_range(0, deploy_width) + edge, RNG.gen.randf_range(0, field_size.y))
	
	return weakref(pawn)
