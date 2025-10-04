extends Node
class_name HealthBar

var creature: Creature
var slowHealthBar: Sprite2D
var healthBar: Sprite2D
var container: PanelContainer

func _init(_creature: Creature, _slowHealthBar: Sprite2D, _healthBar: Sprite2D, _container: PanelContainer) -> void:
	creature = _creature
	slowHealthBar = _slowHealthBar
	healthBar = _healthBar
	container = _container
	return
