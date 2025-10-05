extends Control
class_name UIHealth

@onready var _panelContainer = $PanelContainer

var _healthBars = {}

var _maxDistanceFromPlayer = 40

func _ready() -> void:
	Global.uiHealth = self
	return

func _process(delta: float) -> void:
	updateCreatureHealthBars(delta)
	return

func registerCreatureHealthBar(creature: Creature) -> void:
	var id = str(creature.get_instance_id())
	if _healthBars.has(id):
		return
		
	var panelContainer = _panelContainer.duplicate(DuplicateFlags.DUPLICATE_GROUPS)
	panelContainer.name = id
	add_child(panelContainer)
	
	var healthBar: Sprite2D = panelContainer.get_node("Clip/Bar")
	var slowHealthBar: Sprite2D = panelContainer.get_node("Clip/SlowBar")
	
	var creatureHealthBar: HealthBar = HealthBar.new(creature, slowHealthBar, healthBar, panelContainer)
	_healthBars[id] = creatureHealthBar
	return
	
func unregisterCreatureHealthBar(creature: Creature) -> void:
	var id = str(creature.get_instance_id())
	if !_healthBars.has(id):
		return
	
	var creatureHealthBar: HealthBar = _healthBars[id]
	creatureHealthBar.container.queue_free()
	creatureHealthBar.queue_free()
	
	_healthBars.erase(id)
	return

func updateCreatureHealthBars(delta: float) -> void:
	for key in _healthBars.keys():
		var creatureHealthBar: HealthBar = _healthBars[key]

		if !is_instance_valid(creatureHealthBar):
			_healthBars.erase(key)
			continue
			
		var creature: Creature = creatureHealthBar.creature
		if !is_instance_valid(creature) or creature.isDead():
			creatureHealthBar.container.queue_free()
			creatureHealthBar.queue_free()
			_healthBars.erase(key)
			continue
		
		var shouldBeHidden = creature.getHealth() >= creature.getMaxHealth() \
			or Global.player.global_position.distance_to(creature.global_position) > _maxDistanceFromPlayer 
		shouldBeHidden = false
			
		if shouldBeHidden and creatureHealthBar.container.visible:
			creatureHealthBar.container.hide()
			continue
		
		# update health bar
		var healthPercentage = clamp(creature.getHealth() / creature.getMaxHealth(), 0.0, 1.0)
		var healthPosition = roundi((healthPercentage - 1) * 40.0)
		if creatureHealthBar.healthBar.position.x != healthPosition:
			creatureHealthBar.healthBar.position.x = healthPosition
		
		# update slow health bar
		var slow_position = lerp(creatureHealthBar.slowHealthBar.position.x, creatureHealthBar.healthBar.position.x, delta * 2.0)
		if abs(slow_position - creatureHealthBar.slowHealthBar.position.x) < 0.005:
			slow_position = creatureHealthBar.healthBar.position.x
		if creatureHealthBar.slowHealthBar.position.x != slow_position:
			creatureHealthBar.slowHealthBar.position = Vector2(slow_position, 0)
		
		# update container to fit under creature
		var screenPotision = Global.camera.unproject_position(creature.global_position) + Vector2(0, 10)
		creatureHealthBar.container.position = screenPotision
		
	return
