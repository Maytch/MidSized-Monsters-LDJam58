extends Living

@onready var _camera = $Camera3D

func _ready() -> void:
	Global.player = self
	Global.camera = _camera
	return

func _process(delta: float) -> void:
	super(delta)
	processPlayerInput()
	
	return

func _physics_process(delta: float) -> void:
	super(delta)
	
	return

func processPlayerInput() -> void:
	_moveX = Input.get_axis("move_left", "move_right")
	_moveZ = Input.get_axis("move_forwards", "move_backwards")
	
	return
