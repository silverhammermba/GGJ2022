extends RigidBody2D

export var hp = 100
export var morale = 100
export var speed = 10
export var weight_toward_friends = 1.0
export var weight_follow_herd = 1.0
export var weight_toward_nemesis = 1.0
export var max_turn_per_sec = PI / 4
export var faction = true

var friend_zone: Area2D

var target_dir: Vector2
var nemesis: Vector2

func _ready():
	target_dir = RNG.rand_vec2()
	friend_zone = $FriendZone
	
func set_faction(fac):
	faction = fac
	
	var color: Color
	if faction:
		color = Color(0, 1, 0)
	else:
		color = Color(1, 0, 1)
	$Sprite.modulate = color

func _physics_process(delta):
	var bodies = friend_zone.get_overlapping_bodies()
	
	var pull_angle = 0.0
	var total_weight = 0.0
	var num_friends = 0
	
	if nemesis:
		pull_angle += target_dir.angle_to(nemesis - global_position) * weight_toward_nemesis
		total_weight += weight_toward_nemesis

	for body in bodies:
		if body == self:
			continue
		
		if body.faction == faction:
			num_friends += 1
			pull_angle += target_dir.angle_to(body.global_position - global_position) * weight_toward_friends
			pull_angle += target_dir.angle_to(body.target_dir) * weight_follow_herd
	
	total_weight += (weight_toward_friends + weight_follow_herd) * num_friends
	if total_weight > 0:
		pull_angle /= total_weight
	
	target_dir = target_dir.rotated(clamp(pull_angle, -max_turn_per_sec * delta, max_turn_per_sec * delta))
	
	apply_central_impulse(target_dir * speed)
