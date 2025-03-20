class_name endgame_volume
extends Area2D

@export var isActive:bool = true
var signal_manager: SigBus = Manager
func _on_body_entered(body: Node2D) -> void:
	if isActive and body is Ball:
		(body as Ball).endgame_sinking = true
		signal_manager.emit_signal("endgame")
