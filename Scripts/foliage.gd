@tool
class_name Foliage
extends Node2D

@export var foliage_Texture:Texture2D = load("res://Resources/Textures/Sprites/Reeds2_a1.png"):
	set(t):
		foliage_Texture = t
		#$MeshInstance2D.texture = foliage_Texture
@export var meshOffset := Vector2(0.0, -64.0):
	set(offset):
		meshOffset = offset
		$MeshInstance2D.position = meshOffset
@export var meshScale := Vector2(96.0, 128.0):
	set(scal):
		meshScale = scal
		$MeshInstance2D.scale = meshScale


@onready var mesh := $MeshInstance2D
func _ready() -> void:
	mesh.texture = foliage_Texture
	pass
