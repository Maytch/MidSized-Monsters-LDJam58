extends Node

var player
var camera

var enemyCreatures: Array = []
var friendCreatures: Array = []

var potionCount = 5;
var captureCount = 5;

var potionHealAmount = 20;

enum AreaType { CAPTURE, POTION, SUMMON, ATTACK, ATTACK_FRIEND }

var projectileScene = preload("res://scenes/projectile.tscn")
var areaOfEffectScene = preload("res://scenes/area_of_effect.tscn")

func showError(text: String) -> void:
	print(text)
	return
