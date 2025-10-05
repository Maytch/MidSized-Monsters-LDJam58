extends PanelContainer
class_name StartGame

func _ready() -> void:
	connect("mouse_entered", onMouseEntered)
	connect("mouse_exited", onMouseExited)
	return

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		onPanelClicked()

func onPanelClicked():
	get_tree().change_scene_to_file("res://levels/level1.tscn")
	
func onMouseEntered() -> void:
	add_theme_stylebox_override("panel", Global.uiAssignKeys.highlightedStylebox)
	return
	
func onMouseExited() -> void:
	add_theme_stylebox_override("panel", Global.uiAssignKeys.defaultSylebox)
	return
