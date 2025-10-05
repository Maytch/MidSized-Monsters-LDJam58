extends Node

var player
var camera
var uiHealth: UIHealth
var uiCreatureCollection: UICreatureCollection
var uiError: UIError
var uiHotkeys: UIHotkeys

var enemyCreatures: Array = []
var friendCreatures: Array = []

var creatureCollection = {}

var potionCount = 5;
var captureCount = 5;

var potionHealAmount = 40;

enum AreaType { CAPTURE, POTION, SUMMON, ATTACK, ATTACK_FRIEND }
enum CreatureType { SLIME, FLY, SNEK, MUSH, FIRN, SNEL, BIG_MUSH, DINO }

var projectileScene = preload("res://scenes/projectile.tscn")
var areaOfEffectScene = preload("res://scenes/area_of_effect.tscn")

var slimeScene = preload("res://scenes/slime.tscn")
var flyScene = preload("res://scenes/fly.tscn")
var snekScene = preload("res://scenes/fly.tscn")
var mushScene = preload("res://scenes/fly.tscn")
var firnScene = preload("res://scenes/fly.tscn")
var snelScene = preload("res://scenes/fly.tscn")
var bigMushScene = preload("res://scenes/fly.tscn")
var dinoScene = preload("res://scenes/fly.tscn")

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
	
	
	
	
	
