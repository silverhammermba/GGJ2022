extends RigidBody2D

export var hp = 100
export var morale = 100
export var speed = 10

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
	
	for body in bodies:
		if body != self:
			friend_centroid += body.global_position
			
	friend_centroid /= (bodies.size() - 1)
	
	target_direction = friend_centroid - global_position
	
func _integrate_forces(state):
	applied_force = target_direction * speed
