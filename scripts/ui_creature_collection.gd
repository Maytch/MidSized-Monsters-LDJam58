extends Control
class_name UICreatureCollection

@onready var _scrollContainer = $Panel/ScrollContainer
@onready var _vboxContainer = $Panel/ScrollContainer/VBoxContainer
@onready var _panelContainerTemplate = $Template
@onready var _completionLabel = $Progress

var _previousSelectedPanelContainer: PanelContainer = null

@export var _slimeTexture: Texture2D
@export var _flyTexture: Texture2D
@export var _snekTexture: Texture2D
@export var _mushTexture: Texture2D
@export var _firnTexture: Texture2D
@export var _snelTexture: Texture2D
@export var _bigMushTexture: Texture2D
@export var _dinoTexture: Texture2D

func _ready() -> void:
	Global.uiCreatureCollection = self
	_panelContainerTemplate.hide()
	return

func updateScrollToSelected(index: int) -> void:
	var childCount = _vboxContainer.get_child_count()
	if index >= childCount:
		return
		
	var selectedPanelContainer: PanelContainer = _vboxContainer.get_child(index)
	if _previousSelectedPanelContainer != null:
		_previousSelectedPanelContainer.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	
	selectedPanelContainer.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	_previousSelectedPanelContainer = selectedPanelContainer
	_scrollContainer.ensure_control_visible(selectedPanelContainer)
	
	return
	
func updateCompletion() -> void: 
	var dictionary = {}
	for creatureRecord: CreatureRecord in Global.creatureCollection.values():
		if !dictionary.has(creatureRecord.level):
			dictionary[creatureRecord.level] = true
	
	var completion = dictionary.size() / 8.0
	_completionLabel.text = str(completion * 100.0) + "% Completion"

func updateCollection(creatureChange: bool) -> void:
	updateCompletion()
	
	# remove excess children
	if _vboxContainer.get_child_count() > Global.creatureCollection.size():
		creatureChange = true
		for i in range(_vboxContainer.get_child_count() - 1, Global.creatureCollection.size() - 1, -1):
			var child = _vboxContainer.get_child(i)
			child.queue_free()
	
	# add missing children
	if _vboxContainer.get_child_count() < Global.creatureCollection.size():
		creatureChange = true
		for i in range(_vboxContainer.get_child_count(), Global.creatureCollection.size(), 1):
			var container = _panelContainerTemplate.duplicate(DuplicateFlags.DUPLICATE_GROUPS)
			_vboxContainer.add_child(container)
			container.show()
			print("created panel")
	
	var i = 0
	for creatureRecord: CreatureRecord in Global.creatureCollection.values():
		var container: PanelContainer = _vboxContainer.get_child(i)
		i += 1
		
		var richTextLabel: RichTextLabel = container.get_node("HBoxContainer/RichTextLabel")
		var sprite: Sprite2D = container.get_node("HBoxContainer/Panel/Sprite2D")
		
		richTextLabel.text = creatureRecord.creatureName + "\n" \
			+ "Level: " + str(creatureRecord.level) + "\n" \
			+ "HP: " + str(ceili(creatureRecord.currentHealth)) + " / " + str(ceili(creatureRecord.maxHealth))
		
		if creatureRecord.isSummoned:
			richTextLabel.self_modulate = Color(1.0, 1.0, 1.0, 0.5)
			sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.5)
		else:
			richTextLabel.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			
		if creatureChange:
			var texture = null
			match creatureRecord.creatureType:
				Global.CreatureType.SLIME:
					texture = _slimeTexture
				Global.CreatureType.FLY:
					texture = _flyTexture
				Global.CreatureType.SNEK:
					texture = _snekTexture
				Global.CreatureType.MUSH:
					texture = _mushTexture
				Global.CreatureType.FIRN:
					texture = _firnTexture
				Global.CreatureType.SNEL:
					texture = _snelTexture
				Global.CreatureType.BIG_MUSH:
					texture = _bigMushTexture
				Global.CreatureType.DINO:
					texture = _dinoTexture
			sprite.texture = texture
	
	return
