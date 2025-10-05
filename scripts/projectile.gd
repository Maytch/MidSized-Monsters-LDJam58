extends Node3D
class_name Projectile

@onready var _body = $Body
@onready var _sprite = $Body/Sprite3D

@export var _captureTexture: Texture2D = null
@export var _potionTexture: Texture2D = null
@export var _summonTexture: Texture2D = null
@export var _attackTexture: Texture2D = null
@export var _attackFriendTexture: Texture2D = null

var _projectileType = Global.AreaType.CAPTURE
var _healAmount = 0.0
var _creatureRecordToSummon: CreatureRecord = null
var _damageAmount = 0.0

var _areaOfEffect: AreaOfEffect = null

var _rotationSpeed = 2.0
var _isMovingUp = true
var _isHovering = false
var _spawnLocation = Vector3.ZERO
var _movingUpLocation = Vector3.ZERO
var _hoveringLocation = Vector3.ZERO
var _targetLocation = Vector3.ZERO
var _movementSpeed = 8.0
var _lerpAmount = 0.0
var _totalDistance = 0.0
var _setStartingAreaOfEffectRotation = 0.0

func _process(delta: float) -> void:
	_body.global_rotation = Global.camera.global_rotation * Vector3(1.0, 1.0, 1.0)
	move(delta)
	rotateSprite(delta)
	return

func move(delta: float) -> void:
	_lerpAmount += delta * _movementSpeed
	_lerpAmount = min(_lerpAmount, 1.0)
	
	if _isMovingUp:
		global_position = _spawnLocation.lerp(_movingUpLocation, _lerpAmount)
	elif _isHovering:
		global_position = _movingUpLocation.lerp(_hoveringLocation, _lerpAmount)
	else:
		global_position = _hoveringLocation.lerp(_targetLocation, _lerpAmount)
	
	if _lerpAmount >= 1.0:
		if _isMovingUp:
			_lerpAmount = 0.0
			_isMovingUp = false
			_isHovering = true
		elif _isHovering:
			_lerpAmount = 0.0
			_isHovering = false
		else:
			triggerLanding()
	
	return

func rotateSprite(delta: float) -> void:
	_sprite.rotate(Vector3.FORWARD, delta * _rotationSpeed)
	return

func spawn(spawnLocation: Vector3, targetLocation: Vector3) -> void:
	_spawnLocation = spawnLocation
	_targetLocation = Vector3(targetLocation.x, 0.0, targetLocation.z)
	
	var thirdwayLocation = _spawnLocation.lerp(_targetLocation, 1.0/3.0)
	var twoThirdwayLocation =  _spawnLocation.lerp(_targetLocation, 2.0/3.0)
	_movingUpLocation = Vector3(thirdwayLocation.x, spawnLocation.y * 1.5, thirdwayLocation.z)
	_hoveringLocation = Vector3(twoThirdwayLocation.x, spawnLocation.y * 1.5, twoThirdwayLocation.z)
	
	_totalDistance = (_targetLocation - _spawnLocation).length()
	_movementSpeed /= _totalDistance
	_movementSpeed = clamp(_movementSpeed, 2.0, 8.0)
	
	_lerpAmount = 0.0
	global_position = _spawnLocation
	_isMovingUp = true
	return

func setStartingAreaOfEffectRotation(rotation: float):
	_setStartingAreaOfEffectRotation = rotation
	return
	
func setupCapture() -> void:
	_projectileType = Global.AreaType.CAPTURE
	_sprite.texture = _captureTexture
	_areaOfEffect = spawnAreaOfEffect()
	return

func setupSummon(creatureRecord: CreatureRecord) -> void:
	_projectileType = Global.AreaType.SUMMON
	_creatureRecordToSummon = creatureRecord
	_sprite.texture = _summonTexture
	_areaOfEffect = spawnAreaOfEffect()
	return
	
func setupPotion(healAmount: float) -> void:
	_projectileType = Global.AreaType.POTION
	_healAmount = healAmount
	_sprite.texture = _potionTexture
	_areaOfEffect = spawnAreaOfEffect()
	return
	
func setupAttack(damageAmount: float) -> void:
	_projectileType = Global.AreaType.ATTACK
	_damageAmount = damageAmount
	_sprite.texture = _attackTexture
	_areaOfEffect = spawnAreaOfEffect()
	return
	
func setupAttackFriend(damageAmount: float) -> void:
	_projectileType = Global.AreaType.ATTACK_FRIEND
	_damageAmount = damageAmount
	_sprite.texture = _attackFriendTexture
	_areaOfEffect = spawnAreaOfEffect()
	return
	
func triggerLanding() ->  void:
	match _projectileType:
		Global.AreaType.CAPTURE:
			triggerCapture()
		Global.AreaType.SUMMON:
			triggerSummon()
		Global.AreaType.POTION:
			triggerPotion()
		Global.AreaType.ATTACK:
			triggerAttack()
		Global.AreaType.ATTACK_FRIEND:
			triggerAttackFriend()
			
	_areaOfEffect.queue_free()
	queue_free()
	return
	
func triggerCapture() -> void:
	var creature = getNearestCreatureInRange(1.0, false)
	if creature == null:
		return
	Global.player.playTryCapture()
	
	creature.tryCapture()
	return

func triggerSummon() -> void:
	if _creatureRecordToSummon == null:
		return
	Global.player.playSummon()
		
	var creature: Creature = Global.spawnCreature(_creatureRecordToSummon.creatureType)
	creature.setup(_creatureRecordToSummon)
	Global.add_child(creature)
	creature.global_position = Vector3(global_position.x, 0.0, global_position.z)
	_creatureRecordToSummon.isSummoned = true
	Global.uiCreatureCollection.updateCollection(true)
	return
	
func triggerPotion() -> void:
	Global.player.playHeal()
	var creatures = getCreaturesInRange(1.5, true)
	 
	for i in range(creatures.size()):
		var creature: Creature = creatures[i]
		creature.heal(_healAmount)
	return

func triggerAttack() -> void:
	var creatures = getCreaturesInRange(0.75, true)
	 
	for i in range(creatures.size()):
		var creature: Creature = creatures[i]
		creature.takeDamage(_damageAmount)
	return

func triggerAttackFriend() -> void:
	var creatures = getCreaturesInRange(0.75, false)
	 
	for i in range(creatures.size()):
		var creature: Creature = creatures[i]
		creature.takeDamage(_damageAmount)
	return

func spawnAreaOfEffect() -> AreaOfEffect:
	var areaOfEffect: AreaOfEffect = Global.areaOfEffectScene.instantiate()
	Global.add_child(areaOfEffect)
	areaOfEffect.global_position = Vector3(_targetLocation.x, 0.01, _targetLocation.z)
	areaOfEffect.rotate(Vector3.UP, _setStartingAreaOfEffectRotation)
	areaOfEffect.setTexture(_projectileType)
	return areaOfEffect

func getNearestCreatureInRange(areaRange: float, isFriend: bool) -> Creature:
	var targets = Global.enemyCreatures
	if isFriend:
		targets = Global.friendCreatures
	
	var nearestTarget = null
	var nearestDistance = INF

	for target in targets:
		# Make sure the enemy is valid (not freed)
		if is_instance_valid(target):
			var dist = global_position.distance_to(target.global_position)
			if dist < nearestDistance && dist < areaRange:
				nearestDistance = dist
				nearestTarget = target
		
	return nearestTarget

func getCreaturesInRange(areaRange: float, isFriend: bool) -> Array:
	var creatures: Array = []
	
	var targets = Global.enemyCreatures
	if isFriend:
		targets = Global.friendCreatures

	for target in targets:
		# Make sure the enemy is valid (not freed)
		if is_instance_valid(target):
			var dist = global_position.distance_to(target.global_position)
			if dist < areaRange:
				creatures.append(target)
		
	return creatures
