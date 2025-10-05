extends PanelContainer
class_name KeyAssign

@onready var _key = $VBoxContainer/Key
@export var actionName: String

func _ready() -> void:
	connect("mouse_entered", onMouseEntered)
	connect("mouse_exited", onMouseExited)
	updateKey()
	return

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		onPanelClicked()

func onPanelClicked():
	Global.uiAssignKeys.listenForInput(self)
	
func updateKey() -> void:
	var events = InputMap.action_get_events(actionName)
	for event in events:
		if event is InputEventKey:
			_key.text = " [" + event.as_text_physical_keycode() + "]"
			break
	return

func onMouseEntered() -> void:
	add_theme_stylebox_override("panel", Global.uiAssignKeys.highlightedStylebox)
	return
	
func onMouseExited() -> void:
	add_theme_stylebox_override("panel", Global.uiAssignKeys.defaultSylebox)
	return
