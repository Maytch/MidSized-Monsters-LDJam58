extends Control
class_name UIAssignKeys

@export var defaultSylebox: StyleBoxFlat
@export var highlightedStylebox : StyleBoxFlat

var _keyAssign: KeyAssign = null

func _ready() -> void:
	Global.uiAssignKeys = self
	return

func _unhandled_input(event: InputEvent) -> void:
	if _keyAssign == null:
		return
	
	if event is InputEventKey and event.is_pressed():
		if event.is_echo():
			return
		
		var eventKey: InputEventKey = event
		print(eventKey.physical_keycode)
		assignKeyToAction(_keyAssign.actionName, eventKey)
		_keyAssign.updateKey()
		_keyAssign = null
		return

func listenForInput(keyAssign: KeyAssign) -> void:
	_keyAssign = keyAssign
	return

func assignKeyToAction(actionName: String, eventKey: InputEventKey) -> void:
	
	for event in InputMap.action_get_events(actionName):
		InputMap.action_erase_event(actionName, event)
		
	InputMap.action_add_event(actionName, eventKey)
	
	return
