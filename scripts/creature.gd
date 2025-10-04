extends Living
class_name Creature

enum State { IDLE, WALK, CHASE, ATTACK, DEAD }

var _currentState = State.IDLE
var _aggroTarget = null
var _aggroRange = 2.5
var _attackRange = 0.5

var _behaviourTime = 1.0
var _baseIdleBehaviourTime = 2.0
var _baseWalkBehaviourTime = 2.0
var _baseChaseBehaviourTime = 2.0
@export var _baseAttackBehaviourTime = 1.0
var _randBehaviourTime = 1.0

var _key = ""
@export var _creatureType = Global.CreatureType.SLIME
@export var _creatureName = ""
@export var _isFriend = false
@export var _level = 1
@export var _maxHealth = 10.0
var _currentHealth = _maxHealth
@export var _attackDamage = 2.0
@export var _creatureTexture: Texture2D
@export var _creatureFriendTexture: Texture2D

func _ready() -> void:
	super()
	_movementSpeed *= randf_range(0.9, 1.1)
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
	_maxHealth = creatureRecord.maxHealth
	return

func processBehaviour(delta: float) -> void:
	
	if _currentState == State.DEAD:
		return
		
	_behaviourTime -= delta
	if _behaviourTime <= 0:
		chooseNewBehaviour()
		startNewBehaviour()
	else:
		continueBehaviour()
	
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
	
func continueBehaviour() -> void:
	
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
			
	return
	
func takeDamage(damage: float) -> void:
	_currentHealth -= damage
	if _currentHealth < 0:
		die()
	return

func heal(healAmount: float) -> void:
	_currentHealth += healAmount
	if _currentHealth > _maxHealth:
		_currentHealth = _maxHealth
	return
	
func die() -> void:
	_currentHealth = 0
	_currentState = State.DEAD
	_moveX = 0
	_moveZ = 0
	if _isFriend:
		Global.friendCreatures.erase(self)
	else:
		Global.enemyCreatures.erase(self)
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
	
