extends Node2D

var img = [];
var time = 0.0;
var num = 1;

func _ready():
	for n in range(4):
		img.append(load("res://page%d.png" % n))
	$TextureRect.material.set_shader_param("flip_duration", 3)
	$TextureRect.material.set_shader_param("cylinder_ratio", 0.3)
	$TextureRect.material.set_shader_param("rect", Vector2(800,450))
	$TextureRect.material.set_shader_param("current_page", img[0])
	$TextureRect.material.set_shader_param("next_page", img[1])

func math(delta : float):
	$TextureRect.material.set_shader_param("time", time)
	if time == 0:
		$TextureRect.material.set_shader_param("next_page", img[num])
	time += delta
	if time > 5:
		$TextureRect.material.set_shader_param("current_page", img[num])
		num = (num + 1) % img.size()
		time = 0

func _process(delta : float):
	math(delta)
