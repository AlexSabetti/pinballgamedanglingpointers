class_name DeathVolume
extends Area2D

@export var isActive:bool = true

func _on_body_entered(body: Node2D) -> void:
	if isActive and body is Ball:
		(body as Ball).destroy_ball()
