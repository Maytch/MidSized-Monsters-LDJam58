extends Node3D
class_name Shop

@export var cost = 5
@export var itemType: Global.ItemType = Global.ItemType.POTION

var _maxDistanceFromPlayer = 1.0

func _physics_process(delta: float) -> void:
	if global_position.distance_to(Global.player.global_position) <= _maxDistanceFromPlayer:
		Global.uiShop.showShop(self)
	return
