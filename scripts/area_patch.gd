extends Node3D
class_name AreaPatch

@export var _enemySpawnChance = 0.25
@export var _itemSpawnChance = 0.25

@export var _enemies: Array[Node3D]

func generate(possibleEnemyTypes: Array[Global.CreatureType], possibleMissingEnemyTypes: Array[Global.CreatureType]) -> void:
	var enemySpawns = get_node("EnemySpawns")
	var itemSpawns = get_node("ItemSpawns")
	
	for node: Node3D in enemySpawns.get_children():
		generateEnemy(possibleEnemyTypes, possibleMissingEnemyTypes, node.global_position)
	return
	
func generateEnemy(possibleEnemyTypes: Array[Global.CreatureType], possibleMissingEnemyTypes: Array[Global.CreatureType], position: Vector3) -> void:
	if randf() > _enemySpawnChance:
		return
	
	# favor missing types
	if randf() < 0.6 and possibleMissingEnemyTypes.size() > 0:
		var randomIndex = randi_range(0, possibleMissingEnemyTypes.size() - 1)
		var creatureType: Global.CreatureType = possibleMissingEnemyTypes[randomIndex]
		var creature = Global.spawnCreature(creatureType)
		add_child(creature)
	elif possibleEnemyTypes.size() > 0:
		var randomIndex = randi_range(0, possibleEnemyTypes.size() - 1)
		var creatureType: Global.CreatureType = possibleEnemyTypes[randomIndex]
		var creature = Global.spawnCreature(creatureType)
		add_child(creature)
		
	return
