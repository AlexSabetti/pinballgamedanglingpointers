class_name UnderWaterAmbience
extends AudioStreamPlayer2D

func _ready():
	Global.underWaterAmbi = self

func toggle(on:bool):
	if on:
		self.max_distance = 2700
	else:
		self.max_distance = 2400
