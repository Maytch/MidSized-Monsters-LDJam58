extends Living

@onready var _camera = $Camera3D
@onready var _areaOfEffect: AreaOfEffect = $AreaOfEffect

enum PlayerAction { POTION, CAPTURE, SUMMON }

var _currentAction = PlayerAction.SUMMON
var _cooldownSpeed = 1.0
var _potionCooldown = 0.0
var _maxPotionCooldown = 4.0
var _captureCooldown = 0.0
var _maxCaptureCooldown = 2.0
var _summonCooldown = 0.0
var _maxSummonCooldown = 2.5

var _selectedCreatureToSummon: CreatureRecord = null
var _selectedCreatureIndex = 0

func _ready() -> void:
	super()
	Global.player = self
	Global.camera = _camera
	
	_selectedCreatureToSummon = CreatureRecord.new("creature_1", Global.CreatureType.SLIME, "Slime", 1, 50.0, 50.0, false)
	Global.creatureCollection["creature_1"] = _selectedCreatureToSummon
	Global.uiCreatureCollection.updateCollection(true)
	
	Global.uiShop.updateKey()
	
	Global.uiHotkeys.updateKeys()
	Global.uiHotkeys.updateQuantities(Global.captureCount, Global.potionCount, Global.coinCount)
	
	_currentAction = PlayerAction.SUMMON
	_areaOfEffect.setTexture(Global.AreaType.SUMMON)
	Global.uiHotkeys.highlightSummon()
	return

func _process(delta: float) -> void:
	super(delta)
	cooldownActions(delta)
	updateAreaOfEffect()
	processPlayerInput()
	updateAreaOfEffect()
	
	return

func _physics_process(delta: float) -> void:
	super(delta)
	
	return

func processPlayerInput() -> void:
	_moveX = Input.get_axis("move_left", "move_right")
	_moveZ = Input.get_axis("move_forwards", "move_backwards")
	
	if Input.is_action_just_pressed("select_potion_action"):
		_currentAction = PlayerAction.POTION
		_areaOfEffect.setTexture(Global.AreaType.POTION)
		Global.uiHotkeys.highlightPotion()
	
	if Input.is_action_just_pressed("select_capture_action"):
		_currentAction = PlayerAction.CAPTURE
		_areaOfEffect.setTexture(Global.AreaType.CAPTURE)
		Global.uiHotkeys.highlightCapture()
	
	if Input.is_action_just_pressed("select_summon_action"):
		_currentAction = PlayerAction.SUMMON
		_areaOfEffect.setTexture(Global.AreaType.SUMMON)
		Global.uiHotkeys.highlightSummon()
		
	if Input.is_action_just_pressed("select_summon_down"):
		if _selectedCreatureIndex + 1 >= Global.creatureCollection.size():
			_selectedCreatureIndex = 0
			Global.uiCreatureCollection.updateScrollToSelected(_selectedCreatureIndex)
		else:
			_selectedCreatureIndex += 1
			Global.uiCreatureCollection.updateScrollToSelected(_selectedCreatureIndex)
	
	if Input.is_action_just_pressed("select_summon_up"):
		if _selectedCreatureIndex - 1 < 0:
			_selectedCreatureIndex = Global.creatureCollection.size() - 1
			Global.uiCreatureCollection.updateScrollToSelected(_selectedCreatureIndex)
		else:
			_selectedCreatureIndex -= 1
			Global.uiCreatureCollection.updateScrollToSelected(_selectedCreatureIndex)
			
	if Input.is_action_just_pressed("buy_action"):
		Global.uiShop.tryToBuyItem()
		
	if Input.is_action_just_pressed("select_area"):
		match _currentAction:
			PlayerAction.POTION:
				throwPotion()
			PlayerAction.CAPTURE:
				throwCapture()
			PlayerAction.SUMMON:
				throwSummon()
	
	return
	
func throwPotion() -> void:
	if isActionOnCooldown(_currentAction):
		Global.uiError.showError("Potion still on cooldown!")
		return
	
	if Global.potionCount <= 0:
		Global.uiError.showError("You've run out of potions!")
		return
		
	var projectile = spawnProjectile()
	projectile.setupPotion(Global.potionHealAmount)
	
	Global.potionCount -= 1
	Global.uiHotkeys.updateQuantities(Global.captureCount, Global.potionCount, Global.coinCount)
	_potionCooldown = _maxPotionCooldown
	return
	
func throwCapture() -> void:
	if isActionOnCooldown(_currentAction):
		Global.uiError.showError("Capture still on cooldown!")
		return
	
	if Global.captureCount <= 0:
		Global.uiError.showError("You've run out of captures!")
		return
		
	var projectile = spawnProjectile()
	projectile.setupCapture()
	
	Global.captureCount -= 1
	Global.uiHotkeys.updateQuantities(Global.captureCount, Global.potionCount, Global.coinCount)
	_captureCooldown = _maxCaptureCooldown
	return
	
func throwSummon() -> void:
	if isActionOnCooldown(_currentAction):
		Global.uiError.showError("Summon still on cooldown!")
		return
		
	if _selectedCreatureToSummon == null:
		Global.uiError.showError("No creature selected to summon!")
		return
	
	var results = Global.getCreatureRecordFromIndex(_selectedCreatureIndex)
	var creatureRecord: CreatureRecord = results[0]
	_selectedCreatureIndex = results[1]
	Global.uiCreatureCollection.updateScrollToSelected(_selectedCreatureIndex)
	if creatureRecord == null:
		Global.uiError.showError("No creature found!")
		return
		
	if creatureRecord.isSummoned:
		Global.uiError.showError("Creature already summoned!")
		return
			
	var projectile = spawnProjectile()
	projectile.setupSummon(creatureRecord)
		
	_summonCooldown = _maxSummonCooldown
	return
	
func cooldownActions(delta: float) -> void:
	if _captureCooldown > 0:
		_captureCooldown -= delta * _cooldownSpeed
		_captureCooldown = clamp(_captureCooldown, 0.0, _maxCaptureCooldown)
		
	if _potionCooldown > 0:
		_potionCooldown -= delta * _cooldownSpeed
		_potionCooldown = clamp(_potionCooldown, 0.0, _maxPotionCooldown)
		
	if _summonCooldown > 0:
		_summonCooldown -= delta * _cooldownSpeed
		_summonCooldown = clamp(_summonCooldown, 0.0, _maxSummonCooldown)
	
	Global.uiHotkeys.updateCooldowns(_summonCooldown, _maxSummonCooldown, _captureCooldown, _maxCaptureCooldown, _potionCooldown, _maxPotionCooldown)
	return
	
func isActionOnCooldown(action: PlayerAction) -> bool:
	match action:
		PlayerAction.POTION:
			return _potionCooldown > 0
		PlayerAction.CAPTURE:
			return _captureCooldown > 0
		PlayerAction.SUMMON:
			return _summonCooldown > 0
	return false
	
func updateAreaOfEffect() -> void:
	var shouldShow = !isActionOnCooldown(_currentAction)
	if !shouldShow:
		if _areaOfEffect.visible:
			_areaOfEffect.hide()
		return
		
	if !_areaOfEffect.visible:
		_areaOfEffect.show()
	
	var mousePosition = get_viewport().get_mouse_position()
	var projectFrom = _camera.project_ray_origin(mousePosition)
	var projectDirection = _camera.project_ray_normal(mousePosition)
	
	if projectDirection.y == 0.0:
		return
	
	var yHeight = 0.01
	var t = (yHeight - projectFrom.y) / projectDirection.y
	if t < 0.0:
		return
		
	_areaOfEffect.global_position = projectFrom + projectDirection * t
	
	return

func spawnProjectile() -> Projectile:
	var projectile: Projectile = Global.projectileScene.instantiate()
	Global.add_child(projectile)
	
	var targetPosition = _areaOfEffect.global_position
	var spawnLocation = global_position + global_position.direction_to(_areaOfEffect.global_position) * 0.25
	spawnLocation = Vector3(spawnLocation.x, 0.5, spawnLocation.z)
	
	projectile.spawn(spawnLocation, targetPosition)
	projectile.setStartingAreaOfEffectRotation(_areaOfEffect.rotation.y)
	
	return projectile
