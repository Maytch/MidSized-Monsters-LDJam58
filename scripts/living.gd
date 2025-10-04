extends Node3D
class_name Living

@onready var _body = $Body
@onready var _sprite = $Body/Sprite3D

var _moveX = 0
var _moveZ = 0
@export var _movementSpeed = 5.0

@export var _hasBounce = true
var _previousBodyTargetPosition = Vector3.ZERO
@export var _maxBounceLeft = 0.05
@export var _maxBounceUp = 0.1
var _isBouncingLeft = true
@export var _bounceSpeed = 20

@export var _bodyAnimationSpeed = 2.0
var _currentBodyFrameTime = 0.0

var _hasSpawned = false

func _ready() -> void:
	_hasSpawned = true
	return

func _process(delta: float) -> void:
	if !_hasSpawned:
		return
		
	_body.global_rotation = Global.camera.global_rotation * Vector3(1.0, 1.0, 1.0)
	processMovementBounce(delta)
	processBodyAnimation(delta)
	
	return

func _physics_process(delta: float) -> void:
	if !_hasSpawned:
		return
		
	move(delta)
	
	return

func move(delta: float) -> void:
	var direction = (transform.basis.z * _moveZ) + (transform.basis.x * _moveX)
	direction = direction.normalized()
	
	var velocity = Vector3(direction.x, 0.0, direction.z) * _movementSpeed * delta;
	
	global_position += velocity
	
	return

func processMovementBounce(delta: float) -> void:
	if !_hasBounce:
		return
		
	var newTargetBodyPosition = Vector3.ZERO
	
	if abs(_moveX) + abs(_moveZ) > 0:
		var isLanding = _previousBodyTargetPosition == Vector3.ZERO
		var isCloseToTargetPosition = _body.position.distance_to(_previousBodyTargetPosition) < 0.01
		
		if !isCloseToTargetPosition:
			# I'm not close, keep moving towards target
			newTargetBodyPosition = _previousBodyTargetPosition
		else:
			if isLanding:
				# I have landed, now bounce back up
				_isBouncingLeft = !_isBouncingLeft
				var x = _maxBounceLeft if _isBouncingLeft else -_maxBounceLeft
				newTargetBodyPosition = Vector3(x, _maxBounceUp, 0.0)
			else:
				# I'm at max bounce position, now start landing
				newTargetBodyPosition = Vector3.ZERO
	
	_body.position = lerp(_body.position, newTargetBodyPosition, delta * _bounceSpeed)
	_previousBodyTargetPosition = newTargetBodyPosition
	return

func processBodyAnimation(delta: float) -> void:
	_currentBodyFrameTime -= delta * _bodyAnimationSpeed
	
	if _currentBodyFrameTime <= 0:
		var nextFrame = _sprite.frame + 1
		if nextFrame >= _sprite.hframes:
			nextFrame = 0
			
		_sprite.frame = nextFrame
		_currentBodyFrameTime = 1.0
		
	return
