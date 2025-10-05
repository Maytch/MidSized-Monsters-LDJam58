extends Control
class_name UIError

@onready var _richTextLabel = $RichTextLabel

var _dislayTime = 0.0
var _maxDisplayTime = 2.0

func _ready() -> void:
	Global.uiError = self
	return
	
func _process(delta: float) -> void:
	if _richTextLabel.visible:
		_dislayTime -= delta
		if _dislayTime <= 0:
			_richTextLabel.hide()
	return

func showError(text: String) -> void:
	_richTextLabel.text = text
	_richTextLabel.show()
	_dislayTime = _maxDisplayTime
	return
