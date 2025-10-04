extends Living
class_name Creature

enum State { IDLE, WALK, CHASE, ATTACK, DEAD, IN_CAPTURE }

var _currentState = State.IDLE
var _aggroTarget = null
var _aggroRange = 2.5
var _attackRange = 0.5

var _behaviourTime = 1.0
var _baseIdleBehaviourTime = 2.0
var _baseWalkBehaviourTime = 2.0
var _baseChaseBehaviourTime = 2.0
@export var _baseAttackBehaviourTime = 1.0
var _baseCaptureTime = 3.0
var _randBehaviourTime = 1.0

var _key = ""
@export var _creatureType = Global.CreatureType.SLIME
@export var _creatureName = ""
@export var _isFriend = false
@export var _level = 1
@export var _maxHealth = 10.0
var _currentHealth = 0.0
@export var _attackDamage = 2.0
@export var _creatureTexture: Texture2D
@export var _creatureFriendTexture: Texture2D

@export var _capturingTexture: Texture2D
@export var _capturedTexture: Texture2D
var _isCaptured = false

var _spawnTime = 10.0

func _ready() -> void:
	super()
	_movementSpeed *= randf_range(0.9, 1.1)
	if _currentHealth <= 0:
		_currentHealth = _maxHealth
	
	if _isFriend:
		Global.friendCreatures.append(self)
	else:
		Global.enemyCreatures.append(self)
		
	Global.uiHealth.registerCreatureHealthBar(self)
	
	if _isFriend:
		_sprite.texture = _creatureFriendTexture
	else:
		_sprite.texture = _creatureTexture
		
	if _key == "":
		_key = "creature_" + str(get_instance_id())
	return

func _process(delta: float) -> void:
	super(delta)
	processBehaviour(delta)
	
	return

func _physics_process(delta: float) -> void:
	super(delta)
	
	return

func setup(creatureRecord: CreatureRecord):
	_key = creatureRecord.key
	
	_isFriend = true
	
	_currentHealth = creatureRecord.currentHealth
	return

func processBehaviour(delta: float) -> void:
	
	if _currentState == State.DEAD:
		return
		
	_behaviourTime -= delta
	
	countdownCapture()
	
	if _behaviourTime <= 0:
		chooseNewBehaviour()
		startNewBehaviour()
	else:
		continueBehaviour(delta)
	
	return

func chooseNewBehaviour() -> void:
	var newState = State.IDLE
	
	match _currentState:
		State.IDLE:
			if randf() < 0.6:
				newState = State.WALK
				
		State.WALK:
			if randf() < 0.4:
				newState = State.WALK
				
		State.CHASE:
			if randf() < 0.2:
				newState = State.WALK
				
		State.ATTACK:
			if randf() < 0.2:
				newState = State.WALK
				
		State.IN_CAPTURE:
			if _isCaptured:
				capture()
				return
				
	var nearestTarget = getNearestTarget()
	if nearestTarget != null:
		newState = State.CHASE
		_aggroTarget = nearestTarget
		
		if global_position.distance_to(nearestTarget.global_position) < _attackRange:
			newState = State.ATTACK
			
	_currentState = newState
	
	return
	
func startNewBehaviour() -> void:
	
	match _currentState:
		State.IDLE:
			_behaviourTime = _baseIdleBehaviourTime + randf_range(-_randBehaviourTime, _randBehaviourTime)
			_moveX = 0
			_moveZ = 0
			
		State.WALK:
			var angle = randf() * TAU # 2pi
			var direction = Vector3(cos(angle), 0, sin(angle))
			direction = direction.normalized()
			_moveX = direction.x
			_moveZ = direction.z
			_behaviourTime = _baseWalkBehaviourTime + randf_range(-_randBehaviourTime, _randBehaviourTime)

		State.CHASE:
			var direction = global_position.direction_to(_aggroTarget.global_position)
			direction = direction.normalized()
			_moveX = direction.x
			_moveZ = direction.z
			_behaviourTime = _baseChaseBehaviourTime + randf_range(-_randBehaviourTime, _randBehaviourTime)
			
		State.ATTACK:
			_behaviourTime = _baseAttackBehaviourTime
			_moveX = 0
			_moveZ = 0
			if !_aggroTarget.isDead():
				_aggroTarget.takeDamage(_attackDamage)
			
	return
	
func continueBehaviour(delta: float) -> void:
	
	match _currentState:
		State.CHASE:
			if !is_instance_valid(_aggroTarget):
				chooseNewBehaviour()
				startNewBehaviour()
				return
				
			if global_position.distance_to(_aggroTarget.global_position) < _attackRange:
				_currentState = State.ATTACK
				startNewBehaviour()
				return
				
			var direction = global_position.direction_to(_aggroTarget.global_position)
			direction = direction.normalized()
			_moveX = direction.x
			_moveZ = direction.z
	
	# reduce spawn duration when not in combat
	if _isFriend && _currentState != State.CHASE && _currentState != State.ATTACK:
		_spawnTime -= delta
		if _spawnTime <= 0:
			returnToPlayer()
			
	return
	
func takeDamage(damage: float) -> void:
	if _currentState == State.DEAD or _currentState == State.IN_CAPTURE:
		return
		
	_currentHealth -= damage
	if _currentHealth <= 0:
		die()
		return
	if _isFriend:
		if Global.creatureCollection.has(_key):
			var creatureRecord: CreatureRecord = Global.creatureCollection.get(_key)
			creatureRecord.currentHealth = _currentHealth
			Global.uiCreatureCollection.updateCollection(false)
	return

func heal(healAmount: float) -> void:
	if _currentState == State.DEAD or _currentState == State.IN_CAPTURE:
		return
		
	_currentHealth += healAmount
	if _currentHealth > _maxHealth:
		_currentHealth = _maxHealth
	if _isFriend:
		if Global.creatureCollection.has(_key):
			var creatureRecord: CreatureRecord = Global.creatureCollection.get(_key)
			creatureRecord.currentHealth = _currentHealth
			Global.uiCreatureCollection.updateCollection(false)
	return
	
func tryCapture() -> void:
	if _currentState == State.DEAD or _currentState == State.IN_CAPTURE:
		return
	_moveX = 0
	_moveZ = 0
	_currentState = State.IN_CAPTURE
	_behaviourTime = _baseCaptureTime
	_sprite.texture = _capturingTexture
	return

func countdownCapture() -> void:
	if _currentState != State.IN_CAPTURE or _behaviourTime > 1.0:
		return
	if _isCaptured:
		if _behaviourTime < 0.1:
			capture()
		return
		
	var healthPercentage = getHealth() / getMaxHealth()
	var captureChance = clamp(1.05 - healthPercentage, 0.0, 1.0)
	
	print("chance to capture ", captureChance)
	
	if randf() < captureChance:
		_isCaptured = true
		_sprite.texture = _capturedTexture
	else:
		release()
	return

func capture() -> void:
	print("captured")
	var creatureRecord = CreatureRecord.new(getKey(), getCreatureType(), getCreatureName(), getLevel(), getMaxHealth(), getMaxHealth(), false)
	Global.creatureCollection[creatureRecord.key] = creatureRecord
	Global.uiCreatureCollection.updateCollection(true)
	die()
	return

func release() -> void:
	_currentState = State.IDLE
	_behaviourTime = 0.0
	_sprite.texture = _creatureTexture
	return
	
func die() -> void:
	_currentHealth = 0
	_currentState = State.DEAD
	_moveX = 0
	_moveZ = 0
	if _isFriend:
		Global.friendCreatures.erase(self)
		if Global.creatureCollection.has(_key):
			Global.creatureCollection.erase(_key)
			Global.uiCreatureCollection.updateCollection(true)
	else:
		Global.enemyCreatures.erase(self)
	Global.uiHealth.unregisterCreatureHealthBar(self)
	queue_free()
	return

func returnToPlayer() -> void:
	if _currentHealth < 0:
		die()
		return
		
	_currentState = State.DEAD
	_moveX = 0
	_moveZ = 0
	
	if Global.creatureCollection.has(_key):
		var creatureRecord: CreatureRecord = Global.creatureCollection.get(_key)
		creatureRecord.isSummoned = false
		creatureRecord.currentHealth = _currentHealth
		Global.uiCreatureCollection.updateCollection(true)
	
	Global.friendCreatures.erase(self)
	Global.uiHealth.unregisterCreatureHealthBar(self)
	queue_free()
	return
	
func isDead() -> bool:
	return _currentState == State.DEAD
	
func getHealth() -> float:
	return _currentHealth
	
func getMaxHealth() -> float:
	return _maxHealth
	
func getLevel() -> int:
	return _level

func getCreatureName() -> String:
	return _creatureName
	
func getKey() -> String:
	return _key
	
func getCreatureType() -> Global.CreatureType:
	return _creatureType
	
func getNearestTarget() -> Creature:
	var targets = Global.enemyCreatures
	if !_isFriend:
		targets = Global.friendCreatures
		
	var nearestTarget = null
	var nearestDistance = INF

	for target in targets:
		# Make sure the enemy is valid (not freed)
		if is_instance_valid(target):
			var dist = global_position.distance_to(target.global_position)
			if dist < nearestDistance && dist < _aggroRange:
				nearestDistance = dist
				nearestTarget = target
		
	return nearestTarget
	
