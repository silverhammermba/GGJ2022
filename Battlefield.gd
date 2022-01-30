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

const stomp = preload("res://assets/stomp/stomp.png")
	
var field_size: Vector2
var grass: Sprite
export var deploy_edge = 0
export var deploy_width = 100
export var army_size = 50

# State Variables
var pawn_count
var trues = []
var falses = []

func _ready():
	field_size = get_viewport().get_visible_rect().size
	
	grass = $Grass

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

func reset():
	# Destroy any existing Pawns
	if trues.size() != 0:
		for i in range(army_size):
			var pawn = trues[i].get_ref()
			if pawn:
				pawn.queue_free()
		for i in range(army_size):
			var pawn = falses[i].get_ref()
			if pawn:
				pawn.queue_free()
		trues.clear()
		falses.clear()

	# Clean up blood
	for node in get_tree().get_nodes_in_group("blood_group"):
		remove_child(node)
		node.queue_free()
		
	# Clean up stomps
	for node in get_tree().get_nodes_in_group("stomp_group"):
		remove_child(node)
		node.queue_free()
	
	# Create Pawns
	for _i in range(army_size):
		trues.append(add_pawn(true))
		falses.append(add_pawn(false))
	
	pawn_count = army_size * 2
		
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
	sprite.add_to_group("blood_group")
	sprite.global_position = position
	sprite.scale = Vector2(0.15, 0.3)
	sprite.modulate = Color(1, 1, 1, 0.75)

func halt_pawns():
	for i in range(army_size):
		var pawn = trues[i].get_ref()
		if pawn:
			pawn.halt()
	for i in range(army_size):
		var pawn = falses[i].get_ref()
		if pawn:
			pawn.halt()
			
func evacuate_pawns():
	for i in range(army_size):
		var pawn = trues[i].get_ref()
		if pawn:
			pawn.evacuate()
	for i in range(army_size):
		var pawn = falses[i].get_ref()
		if pawn:
			pawn.evacuate()

func _on_Powers_stomped(position):
	var sprite = Sprite.new()
	sprite.texture = stomp
	add_child_below_node(grass, sprite)
	sprite.add_to_group("stomp_group")
	sprite.modulate = Color(0, 0, 0, 0.1)
	sprite.global_position = position
	# Hacky hardcoded constant based on Stomp's configuration
	sprite.scale = sprite.scale * 0.75 * 0.5 * 0.25
