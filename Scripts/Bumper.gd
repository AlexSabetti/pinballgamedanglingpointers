@tool
class_name Bumper
extends StaticBody2D

@export var idleSpriteFrames:SpriteFrames = load("res://Resources/Textures/Sprites/SpriteFrames/SF_pufferFish_UNPUFFED.tres")
@export var bumpedSpriteFrames:SpriteFrames = load("res://Resources/Textures/Sprites/SpriteFrames/SF_pufferFish_PUFFED.tres")
@export var flip_sprite_horizontally:bool = false:
	set(f):
		flip_sprite_horizontally = f
		if flip_sprite_horizontally:
			$SpriteAxis/AnimatedSprite2D.scale = Vector2(-0.15,0.15)
		else:
			$SpriteAxis/AnimatedSprite2D.scale = Vector2(0.15,0.15)
@export var point_value:int = 10

var bumperActivated:bool = false

@onready var Collider:CollisionShape2D = $CollisionShape2D
@onready var SpriteAxis:Node2D = $SpriteAxis
@onready var Sprite:AnimatedSprite2D = $SpriteAxis/AnimatedSprite2D
@onready var puffTimer:Timer = $Timer
@onready var pointLabel:Label = $PointLabel

func _ready() -> void:
	pass
	
	if flip_sprite_horizontally:
		flip_sprite(true)

# function for when the bumper gets hit
func bumper_hit() -> void:
	print("bumper hit!")
	# makes puffer fish puff up
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.75,1.75), 0.2).from(Vector2(1.0,1.0)).set_trans(Tween.TRANS_ELASTIC)
	pointLabel.text = "+" + str(point_value)
	tween.parallel().tween_property(pointLabel, "scale",  Vector2(1.0,1.0), 0.2).from(Vector2(0.0,0.0)).set_trans(Tween.TRANS_ELASTIC)
	Sprite.sprite_frames = bumpedSpriteFrames
	puffTimer.start()
	
	# plays sound
	SoundManager2D.PlaySoundQueue2DAt("SQ_boink", position)

func flip_sprite(flipped: bool) -> void:
	if flipped:
		Sprite.scale = Vector2(-0.15,0.15)
		flip_sprite_horizontally = true
	else:
		Sprite.scale = Vector2(0.15,0.15)
		flip_sprite_horizontally = false

func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.25).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(pointLabel, "scale",  Vector2(0.0,0.0), 0.25).set_trans(Tween.TRANS_BOUNCE)
	Sprite.sprite_frames = idleSpriteFrames
