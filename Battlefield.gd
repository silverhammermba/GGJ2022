extends Node2D

signal pawns_remaining(count)

const pawn_scene = preload("res://Pawn.tscn")

var field_size: Vector2
export var deploy_edge = 0
export var deploy_width = 100
export var army_size = 50
var pawn_count = army_size * 2

var trues = []
var falses = []

func _ready():
	field_size = get_viewport().get_visible_rect().size
	
	for _i in range(army_size):
		trues.append(add_pawn(true))
		falses.append(add_pawn(false))
		
func _process(_delta):
	var avg_true = Vector2()
	var num_trues = 0
	for i in range(army_size):
		var pawn = trues[i].get_ref()
		if pawn and pawn.morale >= pawn.retreat_threshold:
			num_trues += 1
			avg_true += pawn.global_position

	if num_trues > 0:
		avg_true /= num_trues
	else:
		avg_true = null
	
	var avg_false = Vector2()
	var num_falses = 0
	for i in range(army_size):
		var pawn = falses[i].get_ref()
		if pawn:
			pawn.nemesis = avg_true
			if pawn.morale >= pawn.retreat_threshold:
				num_falses += 1
				avg_false += pawn.global_position

	if num_falses > 0:
		avg_false /= num_falses
	else:
		avg_false = null
	
	for i in range(army_size):
		var pawn = trues[i].get_ref()
		if pawn:
			pawn.nemesis = avg_false

func add_pawn(faction):
	var pawn = pawn_scene.instance()
	add_child(pawn)
	pawn.connect("death", self, "decrement_pawn_count")
	pawn.set_faction(faction)
	var edge = deploy_edge
	if faction:
		pawn.target_dir = Vector2(-1, 0)
		edge = field_size.x - (edge + deploy_width)
	else:
		pawn.target_dir = Vector2(1, 0)
	
	pawn.global_position = Vector2(RNG.gen.randf_range(0, deploy_width) + edge, RNG.gen.randf_range(0, field_size.y))
	
	return weakref(pawn)
	
func decrement_pawn_count():
	pawn_count -= 1
	emit_signal("pawns_remaining", pawn_count)
