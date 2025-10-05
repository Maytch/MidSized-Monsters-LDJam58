extends Control
class_name UIHotkeys

@onready var _summonPanelContainer: PanelContainer = $Panel/HBoxContainer/Summon
@onready var _summonKey: RichTextLabel = $Panel/HBoxContainer/Summon/VBoxContainer/HBoxContainer/Key
@onready var _summonCooldown: PanelContainer = $Panel/HBoxContainer/Summon/Cooldown

@onready var _capturePanelContainer: PanelContainer = $Panel/HBoxContainer/Capture
@onready var _captureKey: RichTextLabel = $Panel/HBoxContainer/Capture/VBoxContainer/HBoxContainer/Key
@onready var _captureQuantity: RichTextLabel = $Panel/HBoxContainer/Capture/VBoxContainer/HBoxContainer/Quantity
@onready var _captureCooldown: PanelContainer = $Panel/HBoxContainer/Capture/Cooldown

@onready var _potionPanelContainer: PanelContainer = $Panel/HBoxContainer/Potion
@onready var _potionKey: RichTextLabel = $Panel/HBoxContainer/Potion/VBoxContainer/HBoxContainer/Key
@onready var _potionQuantity: RichTextLabel = $Panel/HBoxContainer/Potion/VBoxContainer/HBoxContainer/Quantity
@onready var _potionCooldown: PanelContainer = $Panel/HBoxContainer/Potion/Cooldown

var _defaultSylebox: StyleBoxFlat
var _highlightedStylebox : StyleBoxFlat

func _ready() -> void:
	Global.uiHotkeys = self
	_defaultSylebox = _summonPanelContainer.get_theme_stylebox("panel")
	_highlightedStylebox = _potionPanelContainer.get_theme_stylebox("panel")
	return
	
func resetHighlights() -> void:
	_summonPanelContainer.add_theme_stylebox_override("panel", _defaultSylebox)
	_capturePanelContainer.add_theme_stylebox_override("panel", _defaultSylebox)
	_potionPanelContainer.add_theme_stylebox_override("panel", _defaultSylebox)
	return
	
func highlightSummon() -> void:
	resetHighlights()
	_summonPanelContainer.add_theme_stylebox_override("panel", _highlightedStylebox)
	return
	
func highlightCapture() -> void:
	resetHighlights()
	_capturePanelContainer.add_theme_stylebox_override("panel", _highlightedStylebox)
	return
	
func highlightPotion() -> void:
	resetHighlights()
	_potionPanelContainer.add_theme_stylebox_override("panel", _highlightedStylebox)
	return
	

func updateCooldowns(summonCooldown: float, maxSummonCooldown: float, captureCooldown: float, maxCaptureCooldown: float, potionCooldown: float, maxPotionCooldown: float) -> void:
	_summonCooldown.custom_minimum_size = Vector2(64.0, 66.0 * (summonCooldown / maxSummonCooldown))
	_captureCooldown.custom_minimum_size = Vector2(64.0, 66.0 * (captureCooldown / maxCaptureCooldown))
	_potionCooldown.custom_minimum_size = Vector2(64.0, 66.0 * (potionCooldown / maxPotionCooldown))
	return

func updateQuantities(captureQuantity: int, potionQuantity: int) -> void:
	_captureQuantity.text = "x" + str(captureQuantity) + " "
	_potionQuantity.text = "x" + str(potionQuantity) + " "
	return

func updateKeys() -> void:
	var summonEvents = InputMap.action_get_events("select_summon_action")
	for summonEvent in summonEvents:
		if summonEvent is InputEventKey:
			_summonKey.text = " [" + summonEvent.as_text_physical_keycode() + "]"
			break
	var captureEvents = InputMap.action_get_events("select_capture_action")
	for captureEvent in captureEvents:
		if captureEvent is InputEventKey:
			_captureKey.text = " [" + captureEvent.as_text_physical_keycode() + "]"
			break
	var potionEvents = InputMap.action_get_events("select_potion_action")
	for potionEvent in potionEvents:
		if potionEvent is InputEventKey:
			_potionKey.text = " [" + potionEvent.as_text_physical_keycode() + "]"
			break
	return
