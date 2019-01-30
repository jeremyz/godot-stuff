extends Node2D

var img = [];
var time = 0.0;
var num = 1;

func _ready():
	for n in range(4): img.append(load("res://page%d.png" % n))
	$TextureRect.material.set_shader_param("tex1", img[0])

func math():
	$TextureRect.material.set_shader_param("time", time)
	time += 0.01
	if time == 0.01:
		if num == img.size() - 1: num = 0
		$TextureRect.material.set_shader_param("tex2", img[num])
	if time > 3.0:
		$TextureRect.material.set_shader_param("tex1", img[num])
		time = 0.0
		num += 1;

func _process(delta): math()
