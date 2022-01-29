extends Node2D

const pawn_scene = preload("res://Pawn.tscn")

var field_size: Vector2
export var deploy_width = 100
export var army_size = 50

var trues = []
var falses = []

func _ready():
	field_size = get_viewport().get_visible_rect().size
	
	for i in range(army_size):
		trues.append(add_pawn(true))
		falses.append(add_pawn(false))
		
func _physics_process(delta):
	var avg_true = Vector2()
	for i in range(army_size):
		avg_true += trues[i].global_position
	avg_true /= army_size
	
	var avg_false = Vector2()
	for i in range(army_size):
		falses[i].nemesis = avg_true
		avg_false += falses[i].global_position
	avg_false /= army_size
	
	for i in range(army_size):
		trues[i].nemesis = avg_false

func add_pawn(faction):
	var pawn = pawn_scene.instance()
	add_child(pawn)
	pawn.set_faction(faction)
	var deploy_edge = 0
	if faction:
		pawn.target_dir = Vector2(-1, 0)
		deploy_edge = field_size.x - deploy_width
	else:
		pawn.target_dir = Vector2(1, 0)
	
	pawn.global_position = Vector2(RNG.gen.randf_range(0, deploy_width) + deploy_edge, RNG.gen.randf_range(0, field_size.y))
	
	return pawn
