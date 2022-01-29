extends RigidBody2D

export var hp = 100
export var morale = 100
export var speed = 10
export var weight_toward_friends = 1.0
export var weight_follow_herd = 1.0
export var follow_herd_speed_threshold = 1.0

var friend_zone: Area2D

var target_direction = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	friend_zone = $FriendZone

func _physics_process(_delta):
	var bodies = friend_zone.get_overlapping_bodies()
	
	if bodies.size() == 1:
		target_direction = Vector2()
		return
		
	var friend_centroid = Vector2()
	var herd_direction = Vector2()
	
	for body in bodies:
		if body != self:
			friend_centroid += body.global_position
			herd_direction += body.linear_velocity
			
	friend_centroid /= (bodies.size() - 1)
	herd_direction /= (bodies.size() - 1)
	
	var toward_friends = (friend_centroid - global_position).normalized()
	herd_direction = herd_direction.normalized()
	
	var factors = [
		[toward_friends, weight_toward_friends * (bodies.size() - 1)],
		[herd_direction, weight_follow_herd * (bodies.size() - 1)]
	]
	
	var num = Vector2()
	var den = 0
	for factor in factors:
		num += factor[0] * factor[1]
		den += factor[1]
		
	target_direction = num / den
	
func _integrate_forces(state):
	applied_force = target_direction * speed
