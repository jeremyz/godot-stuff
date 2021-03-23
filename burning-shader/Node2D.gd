extends Node2D

var img = [];
var time = 0.0;
var num = 1;

func _ready():
	for n in range(4):
		img.append(load("res://page%d.png" % n))
	$TextureRect.material.set_shader_param("tex1", img[0])
	$TextureRect.material.set_shader_param("tex2", img[1])

func math(delta : float):
	$TextureRect.material.set_shader_param("time", time)
	if time == 0:
		$TextureRect.material.set_shader_param("tex2", img[num])
	time += delta
	if time > 3.0:
		$TextureRect.material.set_shader_param("tex1", img[num])
		num = (num + 1) % img.size()
		time = 0

func _process(delta : float):
	math(delta)
