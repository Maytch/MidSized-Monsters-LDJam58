extends Sprite3D
class_name AreaOfEffect

var _rotationSpeed = 1.0

@export var _captureTexture: Texture2D = null
@export var _potionTexture: Texture2D = null
@export var _summonTexture: Texture2D = null
@export var _attackTexture: Texture2D = null
@export var _attackFriendTexture: Texture2D = null

func _process(delta: float) -> void:
	rotate(Vector3.UP, delta * _rotationSpeed)

func setTexture(areaType: Global.AreaType) -> void:
	match areaType:
		Global.AreaType.CAPTURE:
			texture = _captureTexture
		Global.AreaType.POTION:
			texture = _potionTexture
		Global.AreaType.SUMMON:
			texture = _summonTexture
		Global.AreaType.ATTACK:
			texture = _attackTexture
		Global.AreaType.ATTACK_FRIEND:
			texture = _attackFriendTexture
	return
