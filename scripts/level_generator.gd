extends Node3D
class_name LevelGenerator

@export var _grassPatch: PackedScene

var _delayProcessTime = 0.0
@export var _maxDelayProcessTime = 1.0
var _areaWidth = 6.0

var _areaStore: Dictionary = {}

var _enemyTypes: Dictionary = {}
var _possibleMissingEnemyTypes: Array[Global.CreatureType]
var _possibleEnemyTypes: Array[Global.CreatureType]
var _needToRegeneratePossibleEnemyTypes = true

var _currentPlayerCoord: Vector2i = Vector2i(-999, -999)
var _previousPlayerCoord: Vector2i = Vector2i(-999, -999)

func _ready() -> void:
	_enemyTypes[1] = Global.CreatureType.SLIME
	_enemyTypes[2] = Global.CreatureType.FLY
	_enemyTypes[3] = Global.CreatureType.SNEK
	_enemyTypes[4] = Global.CreatureType.MUSH
	_enemyTypes[5] = Global.CreatureType.FIRN
	_enemyTypes[6] = Global.CreatureType.SNEL
	_enemyTypes[7] = Global.CreatureType.BIG_MUSH
	_enemyTypes[8] = Global.CreatureType.DINO
	
	return
	
func _physics_process(delta: float) -> void:
	_delayProcessTime -= delta
	if _delayProcessTime <= 0:
		_delayProcessTime = _maxDelayProcessTime
		
		_currentPlayerCoord = getCoord(Global.player.global_position)
		if _currentPlayerCoord == _previousPlayerCoord:
			return
		_previousPlayerCoord = _currentPlayerCoord
		
		cleanUpDistantAreas()
		generateAreas()
	return

func generateAreas() -> void:
	_needToRegeneratePossibleEnemyTypes = true
	var coords = getAdjacentCoords(_currentPlayerCoord)
	for coord in coords:
		if !_areaStore.has(coord):
			if _needToRegeneratePossibleEnemyTypes:
				generatePossibleEnemyTypes()
				
			var areaPatch = generateAreaPatch(coord)
			_areaStore[coord] = areaPatch
	return

func getCoord(position: Vector3) -> Vector2i:
	var intX = roundi(position.x / _areaWidth)
	var intZ = roundi(position.z / _areaWidth)
	return Vector2i(intX, intZ)
	
func getAdjacentCoords(coord: Vector2i) -> Array:
	var coords: Array = []
	coords.append(coord)
	coords.append(Vector2i(coord.x - 1, coord.y))
	coords.append(Vector2i(coord.x + 1, coord.y))
	coords.append(Vector2i(coord.x, coord.y - 1))
	coords.append(Vector2i(coord.x, coord.y + 1))
	coords.append(Vector2i(coord.x - 1, coord.y - 1))
	coords.append(Vector2i(coord.x - 1, coord.y + 1))
	coords.append(Vector2i(coord.x + 1, coord.y - 1))
	coords.append(Vector2i(coord.x + 1, coord.y + 1))
	
	coords.append(Vector2i(coord.x + 2, coord.y))
	coords.append(Vector2i(coord.x - 2, coord.y))
	coords.append(Vector2i(coord.x + 2, coord.y - 1))
	coords.append(Vector2i(coord.x - 2, coord.y - 1))
	coords.append(Vector2i(coord.x, coord.y - 2))
	coords.append(Vector2i(coord.x - 1, coord.y - 2))
	coords.append(Vector2i(coord.x - 2, coord.y - 2))
	coords.append(Vector2i(coord.x + 1, coord.y - 2))
	coords.append(Vector2i(coord.x + 2, coord.y - 2))
	return coords
	
func generateAreaPatch(coord: Vector2i) -> AreaPatch:
	var patch: AreaPatch = _grassPatch.instantiate()
	add_child(patch)
	patch.generate(_possibleEnemyTypes, _possibleMissingEnemyTypes)
	patch.global_position = Vector3(coord.x * _areaWidth, 0.0, coord.y * _areaWidth)
	return patch
	
func generatePossibleEnemyTypes() -> void:
	_needToRegeneratePossibleEnemyTypes = false
	var maxLevel = 1
	_possibleMissingEnemyTypes = []
	_possibleEnemyTypes = []
	var existingEnemiesByLevel = {}
	
	# fish out max level and all enemies by level
	for creatureRecord: CreatureRecord in Global.creatureCollection.values():
		existingEnemiesByLevel[creatureRecord.level] = creatureRecord
		if creatureRecord.level > maxLevel:
			maxLevel = creatureRecord.level
	
	# add any early levels that aren't in the collection
	for i in range(1, maxLevel + 2):
		if i > 8:
			continue
		_possibleEnemyTypes.append(_enemyTypes.get(i))
		if !existingEnemiesByLevel.has(i):
			_possibleMissingEnemyTypes.append(_enemyTypes.get(i))
	
	print("existingEnemiesByLevel ", existingEnemiesByLevel.size())
	print("maxLevel ", maxLevel)
	print("_possibleEnemyTypes ", _possibleEnemyTypes.size())
	print("_possibleMissingEnemyTypes ", _possibleMissingEnemyTypes.size())
	
	return

func cleanUpDistantAreas() -> void:
	for key in _areaStore.keys():
		var areaPatch: AreaPatch = _areaStore[key]
		var coord = getCoord(areaPatch.global_position)
		if abs(coord.x - _currentPlayerCoord.x) > 5 \
		or abs(coord.y - _currentPlayerCoord.y) > 5:
			_areaStore.erase(key)
			areaPatch.queue_free()
	return
