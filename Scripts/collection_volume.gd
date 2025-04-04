class_name collection_volume
extends Area2D

@export var isActive:bool = true

func _on_body_entered(body: Node2D) -> void:
	if isActive and body is Ball:
		Global.gameLogic.cam_follow = false
		(body as Ball).destroy_ball()
		Global.gameLogic.add_ball()
		Global.gameLogic.cam_follow = true
