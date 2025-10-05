extends Node3D
class_name LookAtCamera

@onready var _body = $Body

func _physics_process(delta: float) -> void:
	_body.global_rotation = Global.camera.global_rotation * Vector3(1.0, 1.0, 1.0)
	return
