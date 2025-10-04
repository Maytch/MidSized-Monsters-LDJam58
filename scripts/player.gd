extends Living

@onready var _camera = $Camera3D
@onready var _areaOfEffect = $AreaOfEffect

enum PlayerAction { POTION, CAPTURE, SUMMON }

var _currentAction = PlayerAction.CAPTURE
var _cooldownSpeed = 1.0
var _potionCooldown = 0.0
var _maxPotionCooldown = 5.0
var _captureCooldown = 0.0
var _maxCaptureCooldown = 2.0
var _summonCooldown = 0.0
var _maxSummonCooldown = 5.0

func _ready() -> void:
	Global.player = self
	Global.camera = _camera
	return

func _process(delta: float) -> void:
	super(delta)
	cooldownActions(delta)
	processPlayerInput()
	updateAreaOfEffect()
	
	return

func _physics_process(delta: float) -> void:
	super(delta)
	
	return

func processPlayerInput() -> void:
	_moveX = Input.get_axis("move_left", "move_right")
	_moveZ = Input.get_axis("move_forwards", "move_backwards")
	
	if Input.is_action_just_pressed("select_potion"):
		_currentAction = PlayerAction.POTION
	
	if Input.is_action_just_pressed("select_capture"):
		_currentAction = PlayerAction.CAPTURE
	
	if Input.is_action_just_pressed("select_summon"):
		_currentAction = PlayerAction.SUMMON
		
	if Input.is_action_just_pressed("select"):
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
		Global.showError("Potion still on cooldown")
		return
		
	_potionCooldown = _maxPotionCooldown
	return
	
func throwCapture() -> void:
	if isActionOnCooldown(_currentAction):
		Global.showError("Capture still on cooldown")
		return
		
	_captureCooldown = _maxCaptureCooldown
	return
	
func throwSummon() -> void:
	if isActionOnCooldown(_currentAction):
		Global.showError("Summon still on cooldown")
		return
		
	_summonCooldown = _maxSummonCooldown
	return
	
func cooldownActions(delta: float) -> void:
	if _captureCooldown > 0:
		_captureCooldown -= delta * _cooldownSpeed
		
	if _potionCooldown > 0:
		_potionCooldown -= delta * _cooldownSpeed
		
	if _summonCooldown > 0:
		_summonCooldown -= delta * _cooldownSpeed
		
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
