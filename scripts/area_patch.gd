extends Node3D
class_name AreaPatch

enum PatchType { CAVE, CHEST, GRASS, GRASS_LOTS, SHOP_CAPTURE, SHOP_POTION, TREE }

@export var _patchType: PatchType = PatchType.GRASS
@export var _enemySpawnChance = 0.25
@export var _itemSpawnChance = 0.25

var _chanceMultiplier = 1.0

var _itemsSpawned = 0
var _enemiesSpawned = 0

func generate(possibleEnemyTypes: Array[Global.CreatureType], possibleMissingEnemyTypes: Array[Global.CreatureType]) -> void:
	var enemySpawns = get_node("EnemySpawns")
	var itemSpawns = get_node("ItemSpawns")
	
	for node: Node3D in enemySpawns.get_children():
		generateEnemy(possibleEnemyTypes, possibleMissingEnemyTypes, node.position)
	
	for node: Node3D in itemSpawns.get_children():
		generateItem(node.position)
		
	#print(PatchType.find_key(_patchType), " enemies ", _enemiesSpawned, " items ", _itemsSpawned)
	return
	
func generateEnemy(possibleEnemyTypes: Array[Global.CreatureType], possibleMissingEnemyTypes: Array[Global.CreatureType], nodePosition: Vector3) -> void:
	if randf() > _enemySpawnChance * _chanceMultiplier:
		return
	
	_enemiesSpawned += 1
	
	# favor missing types
	if randf() < 0.6 and possibleMissingEnemyTypes.size() > 0:
		var randomIndex = randi_range(0, possibleMissingEnemyTypes.size() - 1)
		var creatureType: Global.CreatureType = possibleMissingEnemyTypes[randomIndex]
		var creature = Global.spawnCreature(creatureType)
		add_child(creature)
		creature.position = nodePosition
	elif possibleEnemyTypes.size() > 0:
		var randomIndex = randi_range(0, possibleEnemyTypes.size() - 1)
		var creatureType: Global.CreatureType = possibleEnemyTypes[randomIndex]
		var creature = Global.spawnCreature(creatureType)
		add_child(creature)
		creature.position = nodePosition
		
	return
	
func generateItem(nodePosition: Vector3) -> void:
	if randf() > _itemSpawnChance * _chanceMultiplier:
		return
		
	_itemsSpawned += 1
		
	if randf() < 0.9:
		var coin: Item = Global.coinScene.instantiate()
		add_child(coin)
		coin.position = nodePosition
		return
	
	if randf() < 0.5:
		var potion: Item = Global.potionScene.instantiate()
		add_child(potion)
		potion.position = nodePosition
		return
	
	var capture: Item = Global.captureScene.instantiate()
	add_child(capture)
	capture.position = nodePosition
	return
