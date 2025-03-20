class_name Collectable
extends Area2D

@export var idleSpriteFrames:SpriteFrames = load("res://Resources/Textures/Sprites/SpriteFrames/SF_greyFish.tres")
@export var point_value:int = 10
# whether or not the collectable is able to be collected
var isActive:bool = true


@onready var Collider:CollisionShape2D = $CollisionShape2D
@onready var Sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var timer:Timer = $Timer

# function for when the bumper gets hit
func collectable_hit() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.2).from(Vector2(1.0,1.0)).set_trans(Tween.TRANS_ELASTIC)
	print("colected!!")
	SoundManager2D.PlaySoundQueue2D("SQ_slip")
	Global.gameLogic.update_points(point_value)
	isActive = false


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC)
	isActive = true
