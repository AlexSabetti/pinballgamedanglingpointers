class_name camera_endgame
extends Camera2D

var signal_manager: SigBus = Manager
@export var monitor_ball: Ball
var endgame: bool = false
func _ready():
	signal_manager.connect("endgame",_on_endgame)

func _on_endgame():
	endgame = true

func _process(_delta):
	if endgame:
		position = monitor_ball.global_position
