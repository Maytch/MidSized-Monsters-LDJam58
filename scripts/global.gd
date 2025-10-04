extends Node

var player
var camera

var enemyCreatures: Array = []
var friendCreatures: Array = []

var potionCount = 5;
var captureCount = 5;

func showError(text: String) -> void:
	print(text)
	return
