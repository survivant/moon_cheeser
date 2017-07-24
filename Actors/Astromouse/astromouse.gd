extends RigidBody2D

signal died
export (float) var jump_force = 300
var can_jump = true

onready var default_gravity_scale = get_gravity_scale()

func _ready():
	if get_parent().get_parent().has_method("change_to_next_scene"):
		connect("died", get_parent().get_parent(), "change_to_next_scene", ["res://Screens/Score_Screen/ScoreScreen.tscn"])

func jump():
	if can_jump:
		var direction = Vector2(0, -1)
		apply_impulse(Vector2(0,0), jump_force * direction)
	can_jump = false

func _body_enter( body ):
	if body.is_in_group("moon"):
		can_jump = true
		
	elif body.is_in_group("enemy"):
		print(body.get_name())
		emit_signal("died")
		
	elif body.is_in_group("cheese"):
		body.queue_free()