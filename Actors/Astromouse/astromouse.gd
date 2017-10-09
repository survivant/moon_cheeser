#MIT License
#
#Copyright (c) 2017 Pigdev Studio
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
extends RigidBody2D

signal died
signal finished_sfx
export (float) var jump_force = 300
var can_jump = true
var invulnerable = true
var jump_normal = Vector2(0, -1)
onready var default_gravity_scale = get_gravity_scale()

func _ready():
	get_node("Sprite").set_texture(load("res://Actors/Astromouse/true_astro_spritesheet.png"))
	set_fixed_process(true)
	connect("died", get_parent().get_parent(), "change_to_next_scene", ["res://Screens/Score_Screen/ScoreScreen.tscn"])
		
func _fixed_process(delta):
	is_falling()
func jump():
	if can_jump:
		apply_impulse(Vector2(0,0), jump_force * jump_normal)
		get_node("Sprite").set_frame(2)
		get_node("Animator").stop()
		get_node("SFX").emit_signal("is_playing", "jumping")
	can_jump = false

func _body_enter( body ):
	if body.is_in_group("moon"):
		jump_normal = (get_pos() - body.get_pos()).normalized()
		rotate(get_angle_to(body.get_pos()))
		get_node("Animator").play("walking")
		can_jump = true
		
	elif body.is_in_group("enemy"):
		if body.is_in_group("void"):
			get_node("SFX").play("falling")
			get_node("Animator").play("death")
			emit_signal("died")
		elif not invulnerable:
			get_node("Sprite").hide()
			get_node("SFX").play("damage")
			emit_signal("died")
		
	elif body.is_in_group("cheese"):
		get_node("SFX").emit_signal("is_playing", "pickup")
		body.increase_score()
		
func is_falling():
	if get_parent().get_game_state() == 0:
		var normal = (get_node("../Moon").get_pos() - get_pos()).normalized()
		var falling_speed = normal.dot(get_linear_velocity())
		if falling_speed > 5 and falling_speed < 60:
			get_node("Sprite").set_frame(1)
			rotate(get_angle_to(get_node("../Moon").get_pos()))
			return(true)
		elif falling_speed > 100:
			get_node("Sprite").set_frame(3)
			return(true)
		else:
			return(false)

func _invulnerability():
	invulnerable = false
