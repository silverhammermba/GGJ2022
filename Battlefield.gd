extends Node2D

signal pawns_remaining(count)

const pawn_scene = preload("res://Pawn.tscn")

const blood = [
	preload("res://assets/bloodsplats_128x128/bloodsplats_0001.png"),
	preload("res://assets/bloodsplats_128x128/bloodsplats_0002.png"),
	preload("res://assets/bloodsplats_128x128/bloodsplats_0003.png"),
	preload("res://assets/bloodsplats_128x128/bloodsplats_0004.png"),
	preload("res://assets/bloodsplats_128x128/bloodsplats_0005.png"),
	preload("res://assets/bloodsplats_128x128/bloodsplats_0006.png"),
	preload("res://assets/bloodsplats_128x128/bloodsplats_0007.png"),
]

var field_size: Vector2
export var deploy_edge = 0
export var deploy_width = 100
export var army_size = 50
var pawn_count = army_size * 2

var trues = []
var falses = []
var grass: Sprite

func _ready():
	field_size = get_viewport().get_visible_rect().size
	
	grass = $Grass
	
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
	
func decrement_pawn_count(position):
	pawn_count -= 1
	add_blood(position)
	emit_signal("pawns_remaining", pawn_count)
	
func add_blood(position):
	var sprite = Sprite.new()
	sprite.texture = blood[RNG.gen.randi_range(0, blood.size() - 1)]
	add_child_below_node(grass, sprite)
	sprite.global_position = position
	sprite.scale = Vector2(0.15, 0.15)
	sprite.modulate = Color(1, 1, 1, 0.75)
