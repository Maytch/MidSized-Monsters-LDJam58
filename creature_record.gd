extends Node
class_name CreatureRecord

var key: String
var creatureType: Global.CreatureType
var creatureName: String
var level: int
var currentHealth: float
var maxHealth: float
var isSummoned: bool

func _init(_key: String, _creatureType: Global.CreatureType, _creatureName: String, _level: int, _currentHealth: float, _maxHealth: float, _isSummoned: bool) -> void:
	key = _key
	creatureType = _creatureType
	creatureName = _creatureName
	level = _level
	currentHealth = _currentHealth
	maxHealth = _maxHealth
	isSummoned = _isSummoned
	return
