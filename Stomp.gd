extends Node2D

export var strength = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_viewport().get_mouse_position()

func _on_Stomp_body_entered(body):
	print("Stomped " + body.name)
	body.hit(strength)
