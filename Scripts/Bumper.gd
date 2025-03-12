class_name Bumper
extends StaticBody2D

@export var idleSpriteFrames:SpriteFrames = load("res://Resources/Textures/Sprites/SpriteFrames/SF_pufferFish_UNPUFFED.tres")
@export var bumpedSpriteFrames:SpriteFrames = load("res://Resources/Textures/Sprites/SpriteFrames/SF_pufferFish_PUFFED.tres")
var bumperActivated:bool = false
var signal_manager: SignalBus = SignalManager

@onready var Collider:CollisionShape2D = $CollisionShape2D
@onready var Sprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var puffTimer:Timer = $Timer

func _ready() -> void:
	
	signal_manager.connect("bumper_hit", bumper_hit)
	


func bumper_hit() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.75,1.75), 0.2).from(Vector2(1.0,1.0)).set_trans(Tween.TRANS_ELASTIC)
	Sprite.sprite_frames = bumpedSpriteFrames
	puffTimer.start()
	print("PUFF!")
	SoundManager2D.PlaySoundQueue2D("SQ_boink")


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.25).set_trans(Tween.TRANS_BOUNCE)
	Sprite.sprite_frames = idleSpriteFrames
