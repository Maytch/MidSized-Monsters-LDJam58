extends Node3D
class_name Item

@onready var _body = $Body
@onready var _sprite = $Body/Sprite3D

@export var _itemType: Global.ItemType = Global.ItemType.POTION

@export var _bodyAnimationSpeed = 2.0
var _currentBodyFrameTime = 0.0

var _distanceToPlayer = 0.25

func _physics_process(delta: float) -> void:
	_body.global_rotation = Global.camera.global_rotation * Vector3(1.0, 1.0, 1.0)
	
	processBodyAnimation(delta)
	
	if global_position.distance_to(Global.player.global_position) < _distanceToPlayer:
		match _itemType:
			Global.ItemType.POTION:
				Global.potionCount += 1
				Global.player.playItemPickup()
			Global.ItemType.CAPTURE:
				Global.captureCount += 1
				Global.player.playItemPickup()
			Global.ItemType.COIN:
				Global.coinCount += 1
				Global.player.playCoinPickup()
		Global.uiHotkeys.updateQuantities(Global.captureCount, Global.potionCount, Global.coinCount)
		queue_free()
	return

func processBodyAnimation(delta: float) -> void:
	if _sprite.hframes == 1:
		return
		
	_currentBodyFrameTime -= delta * _bodyAnimationSpeed
	
	if _currentBodyFrameTime <= 0:
		var nextFrame = _sprite.frame + 1
		if nextFrame >= _sprite.hframes:
			nextFrame = 0
			
		_sprite.frame = nextFrame
		_currentBodyFrameTime = 1.0
		
	return
