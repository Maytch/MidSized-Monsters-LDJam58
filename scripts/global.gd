extends Node

var player: Player
var camera: Camera3D
var uiHealth: UIHealth
var uiCreatureCollection: UICreatureCollection
var uiError: UIError
var uiHotkeys: UIHotkeys
var uiShop: UIShop
var uiAssignKeys: UIAssignKeys

var enemyCreatures: Array = []
var friendCreatures: Array = []

var creatureCollection = {}

var potionCount = 5;
var captureCount = 5;
var coinCount = 5;

var potionHealAmount = 40;

enum AreaType { CAPTURE, POTION, SUMMON, ATTACK, ATTACK_FRIEND }
enum CreatureType { SLIME, FLY, SNEK, MUSH, FIRN, SNEL, BIG_MUSH, DINO }
enum ItemType { POTION, CAPTURE, COIN }

var projectileScene = preload("res://scenes/projectile.tscn")
var areaOfEffectScene = preload("res://scenes/area_of_effect.tscn")

var slimeScene = preload("res://scenes/slime.tscn")
var flyScene = preload("res://scenes/fly.tscn")
var snekScene = preload("res://scenes/snek.tscn")
var mushScene = preload("res://scenes/mush.tscn")
var firnScene = preload("res://scenes/firn.tscn")
var snelScene = preload("res://scenes/snel.tscn")
var bigMushScene = preload("res://scenes/big_mush.tscn")
var dinoScene = preload("res://scenes/dino.tscn")

var potionScene = preload("res://scenes/item_potion.tscn")
var captureScene = preload("res://scenes/item_capture.tscn")
var coinScene = preload("res://scenes/item_coin.tscn")

func spawnCreature(creatureType: CreatureType) -> Creature:
	var object = null
	match creatureType:
		CreatureType.SLIME:
			object = slimeScene.instantiate()
		CreatureType.FLY:
			object = flyScene.instantiate()
		CreatureType.SNEK:
			object = snekScene.instantiate()
		CreatureType.MUSH:
			object = mushScene.instantiate()
		CreatureType.FIRN:
			object = firnScene.instantiate()
		CreatureType.SNEL:
			object = snelScene.instantiate()
		CreatureType.BIG_MUSH:
			object = bigMushScene.instantiate()
		CreatureType.DINO:
			object = dinoScene.instantiate()
		
	return object
	
func getCreatureRecordFromIndex(index: int) -> Array:
	var i = 0
	for creatureRecord: CreatureRecord in creatureCollection.values():
		if i == index:
			return [creatureRecord, index]
		if i == creatureCollection.size() - 1:
			return [creatureRecord, i]
		i += 1
	return [null, 0]
	
	
	
	
	
