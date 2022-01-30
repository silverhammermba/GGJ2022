extends RigidBody2D

signal death

export var max_stat = 100.0
export var hp = 100.0
export var morale = 100.0
export var speed_out_of_combat = 1
export var speed_in_combat = 0.5
export var weight_toward_friends = 1.0
export var weight_follow_herd = 1.0
export var weight_toward_nemesis = 1.0
export var max_turn_per_sec = PI / 4
export var faction = true
export var attack_power = 5
export var attack_delay = 1
export var damage_force_scale = 1
export var max_outnumber = 10
export var morale_herd_per_sec = 1
export var morale_outnumber_per_sec = 1
export var morale_hp_per_sec = 1
export var retreat_threshold = 30
export var stun_delay = 0.5

var viewport_size
var speed = speed_out_of_combat

var friend_zone: Area2D

var target_dir: Vector2
var nemesis = null
var outside_impulse: Vector2
var sprite

var attack_timer: Timer

var attack_target: RigidBody2D

var health_bar: ColorRect
var morale_bar: ColorRect
var health_max_size
var morale_max_size

var sent_death = false
var is_stunned = false
var enable_stun = false
var disable_stun = false

enum Routine { NORMAL, EVACUATE }
var routine = Routine.NORMAL


func _ready():
	viewport_size = get_viewport().size
	sprite = $Sprite
	hp = max_stat
	morale = max_stat
	target_dir = RNG.rand_vec2()
	friend_zone = $FriendZone
	health_bar = $HealthBar
	morale_bar = $MoraleBar
	health_max_size = health_bar.rect_size.x
	morale_max_size = morale_bar.rect_size.x
	attack_timer = $Timer
	attack_timer.start(attack_delay)
	attack_timer.set_paused(true)
	
func set_faction(fac):
	faction = fac
	
	var color: Color
	if faction:
		color = Color(0.52, 0.52, 0.52)
	else:
		color = Color(0.9, 0.8, 0)
	sprite.modulate = color
	
func terrify(amount, force, source):
	morale -= amount
	outside_impulse += source.direction_to(global_position) * force
	
func damage(amount, force, source: Vector2):
	hp -= amount

	if hp <= 0:
		queue_free()
		if not sent_death:
			sent_death = true
			emit_signal("death", global_position)
	else:
		outside_impulse += source.direction_to(global_position) * force
	
func stun():
	if !is_stunned:
		enable_stun = true
		$StunTimer.start(stun_delay)
	
func start_attacking(body):
	if !attack_target and "faction" in body and body.faction != faction:
		attack_timer.set_paused(false)
		attack_target = body
		speed = speed_in_combat
		
func stop_attacking(body):
	if body == attack_target:
		attack_target = null
		speed = speed_out_of_combat
		
func attack_current_target():
	if attack_target:
		attack_target.damage(attack_power, attack_power * damage_force_scale, global_position)
		
func evacuate():
	routine = Routine.EVACUATE
		
func _physics_process(delta):
	if enable_stun:
		get_node("CollisionShape2D").disabled = true
		enable_stun = false
		is_stunned = true
	elif disable_stun:
		get_node("CollisionShape2D").disabled = false
		disable_stun = false
		is_stunned = false
	
	if routine == Routine.NORMAL:
		if hp < max_stat:
			health_bar.set_size(Vector2((1 - hp / max_stat) * health_max_size, health_bar.rect_size.y))
			health_bar.show()
		morale_bar.set_size(Vector2((1 - morale / max_stat) * morale_max_size, morale_bar.rect_size.y))
		if morale < max_stat:
			morale_bar.show()
		else:
			morale_bar.hide()
		
		var bodies = friend_zone.get_overlapping_bodies()
		
		var pull_angle = 0.0
		var total_weight = 0.0
		var num_friends = 0
		var num_enemies = 0
		var morale_from_following_herd = 0

		for body in bodies:
			if body == self:
				continue
			
			if body.faction == faction:
				num_friends += 1
				pull_angle += target_dir.angle_to(body.global_position - global_position) * weight_toward_friends
				var angle_to_friend = target_dir.angle_to(body.target_dir)
				pull_angle += angle_to_friend * weight_follow_herd
				
				# -1 to 1 for going in opposite/same direction as friend
				morale_from_following_herd += 1 - 2 * abs(angle_to_friend) / PI
			else:
				num_enemies += 1
		
		# average over all friends
		if num_friends > 0:
			morale_from_following_herd /= num_friends
		# if enemies are near, you can regain some morale by having more friends (or lose it for being outnumbered)
		var morale_from_outnumber = 0.5
		if num_enemies > 0:
			morale_from_outnumber = clamp((num_friends - num_enemies) / max_outnumber, -1, 1)
		# -1 to 0 for current hp
		var morale_from_hp = hp / max_stat - 1
		
		var delta_morale = (morale_from_following_herd * morale_herd_per_sec + morale_from_outnumber * morale_outnumber_per_sec + morale_from_hp * morale_hp_per_sec)
		morale = clamp(morale + delta_morale * delta, 0, max_stat)

		# if completely demoralized, allow past barriers
		set_collision_mask_bit(2, morale > 0)
		
		total_weight += (weight_toward_friends + weight_follow_herd) * num_friends

		var current_speed = speed
		if nemesis:
			if morale < retreat_threshold:
				# all that matters now is getting away from the enemy
				pull_angle = target_dir.angle_to(global_position - nemesis)
				total_weight = 1
			else:	
				pull_angle += target_dir.angle_to(nemesis - global_position) * weight_toward_nemesis
				total_weight += weight_toward_nemesis
		else:
			current_speed = 0
			
		if total_weight > 0:
			pull_angle /= total_weight
		
		target_dir = target_dir.rotated(clamp(pull_angle, -max_turn_per_sec * delta, max_turn_per_sec * delta))
		
		apply_central_impulse(target_dir * current_speed)
		apply_central_impulse(outside_impulse)
		outside_impulse = Vector2()

	elif routine == Routine.EVACUATE:
		set_collision_mask_bit(2, false)
		speed = 10
		if faction:
			apply_central_impulse(Vector2(1,0))
		else:
			apply_central_impulse(Vector2(-1,0))

func _on_Pawn_body_entered(body):
	start_attacking(body)

func _on_Pawn_body_exited(body):
	stop_attacking(body)

func _on_Timer_timeout():
	attack_current_target()

func _on_StunTimer_timeout():
	$StunTimer.stop()
	disable_stun = true
