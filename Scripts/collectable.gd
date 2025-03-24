@tool
class_name Collectable
extends Area2D

@export_category("visuals")
@export var idleSpriteFrames:SpriteFrames = load("res://Resources/Textures/Sprites/SpriteFrames/SF_greyFish.tres"):
	set(sp):
		idleSpriteFrames = sp
@export var flip_sprite_horizontally:bool = false:
	set(f):
		flip_sprite_horizontally = f
		if flip_sprite_horizontally:
			$SpriteAxis/AnimatedSprite2D.scale = Vector2(-0.15,0.15)
		else:
			$SpriteAxis/AnimatedSprite2D.scale = Vector2(0.15,0.15)
@export_category("mechanics")
@export var point_value:int = 10
@export var respawn_time:float = 5.0
@export var collision_capsule_radius:float = 3.0:
	set(r):
		collision_capsule_radius = r
		($CollisionShape2D.shape as CapsuleShape2D).radius = collision_capsule_radius
@export var collision_capsule_height:float = 10.0:
	set(h):
		collision_capsule_height = h
		($CollisionShape2D.shape as CapsuleShape2D).height = collision_capsule_height
# whether or not the collectable is able to be collected
var isCollectable:bool = true


@onready var Collider:CollisionShape2D = $CollisionShape2D
@onready var SpriteAxis:Node2D = $SpriteAxis
@onready var Sprite:AnimatedSprite2D = $SpriteAxis/AnimatedSprite2D
@onready var timer:Timer = $Timer
@onready var pointLabel:Label = $PointLabel

func _ready() -> void:
	Sprite.sprite_frames = idleSpriteFrames
	timer.wait_time = respawn_time
	
	if flip_sprite_horizontally:
		flip_sprite(true)
	
	(Collider.shape as CapsuleShape2D).radius = collision_capsule_radius
	(Collider.shape as CapsuleShape2D).height = collision_capsule_height

# function for when the bumper gets hit
func collectable_hit() -> void:
	isCollectable = false
	var tween = create_tween()
	tween.tween_property(SpriteAxis, "scale", Vector2(0.0, 0.0), 1.0).from(Vector2(1.0,1.0)).set_trans(Tween.TRANS_ELASTIC)
	if flip_sprite_horizontally:
		tween.parallel().tween_property(SpriteAxis, "rotation_degrees", -90.0, 0.5).from(0.0).set_trans(Tween.TRANS_CIRC)
	else:
		tween.parallel().tween_property(SpriteAxis, "rotation_degrees", 90.0, 0.5).from(0.0).set_trans(Tween.TRANS_CIRC)
	#tween.parallel().tween_property(SpriteAxis, "position", Vector2(0.0,-50.0), 1.0).from(Vector2(0.0, 0.0)).set_trans(Tween.TRANS_ELASTIC)
	
	pointLabel.text = "+" + str(point_value)
	tween.parallel().tween_property(pointLabel, "scale",  Vector2(1.0,1.0), 0.2).from(Vector2(0.0,0.0)).set_trans(Tween.TRANS_ELASTIC)
	tween.chain().tween_property(pointLabel, "scale",  Vector2(0.0,0.0), 0.2).set_trans(Tween.TRANS_ELASTIC)
	
	SoundManager2D.PlaySoundQueue2DAt("SQ_chaching", position)
	
	timer.start(0.0)

func flip_sprite(flipped: bool) -> void:
	if flipped:
		Sprite.scale = Vector2(-0.15,0.15)
		flip_sprite_horizontally = true
	else:
		Sprite.scale = Vector2(0.15,0.15)
		flip_sprite_horizontally = false

func _on_timer_timeout() -> void:
	var tween = create_tween()
	
	SpriteAxis.rotation_degrees = 0.0
	#SpriteAxis.position = Vector2.ZERO
	tween.tween_property(SpriteAxis, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC)
	pointLabel.scale = Vector2.ZERO
	isCollectable = true
	print("collectable reactivated")

# check for when bodies enter the area2D
func _on_body_entered(body: Node2D) -> void:
	# if the body entering is the ball
	if isCollectable and body is Ball:
		collectable_hit()
		print("collectable hit!")
		(body as Ball).signal_manager.emit_signal("add_points", point_value) # emit signal to add points
