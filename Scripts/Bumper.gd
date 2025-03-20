class_name Bumper
extends StaticBody2D

@export var idleSpriteFrames:SpriteFrames = load("res://Resources/Textures/Sprites/SpriteFrames/SF_pufferFish_UNPUFFED.tres")
@export var bumpedSpriteFrames:SpriteFrames = load("res://Resources/Textures/Sprites/SpriteFrames/SF_pufferFish_PUFFED.tres")
@export var point_value:int = 10

var bumperActivated:bool = false
var signal_manager: SigBus = Manager

@onready var Collider:CollisionShape2D = $CollisionShape2D
@onready var Sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var puffTimer:Timer = $Timer
@onready var pointLabel:Label = $PointLabel

func _ready() -> void:
	#signal_manager.connect("bumper_hit", bumper_hit)
	pass
	

# function for when the bumper gets hit
func bumper_hit() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.75,1.75), 0.2).from(Vector2(1.0,1.0)).set_trans(Tween.TRANS_ELASTIC)
	pointLabel.text = "+" + str(point_value)
	tween.parallel().tween_property(pointLabel, "scale",  Vector2(1.0,1.0), 0.2).from(Vector2(0.0,0.0)).set_trans(Tween.TRANS_ELASTIC)
	Sprite.sprite_frames = bumpedSpriteFrames
	puffTimer.start()
	print("PUFF!")
	SoundManager2D.PlaySoundQueue2D("SQ_boink")
	Global.gameLogic.update_points(point_value)


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.25).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(pointLabel, "scale",  Vector2(0.0,0.0), 0.25).set_trans(Tween.TRANS_BOUNCE)
	Sprite.sprite_frames = idleSpriteFrames
