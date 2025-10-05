extends Control
class_name UIShop

@onready var _buyPanelContainer: PanelContainer = $Buy
@onready var _buyKey: RichTextLabel = $Buy/VBoxContainer/HBoxContainer/Key
@onready var _buyCost: RichTextLabel = $Buy/VBoxContainer/HBoxContainer/Cost

var _maxDistanceFromPlayer = 1.0
var _currentShop: Shop = null

func _ready() -> void:
	Global.uiShop = self
	return
	
func _physics_process(delta: float) -> void:
	if _currentShop != null and _currentShop.global_position.distance_to(Global.player.global_position) > _maxDistanceFromPlayer:
		_currentShop = null
		_buyPanelContainer.hide()
		return
	return
	
func updateCost(cost: int) -> void:
	_buyCost.text = "x" + str(cost) + " "
	return

func updateKey() -> void:
	var buyEvents = InputMap.action_get_events("buy_action")
	for buyEvent in buyEvents:
		if buyEvent is InputEventKey:
			_buyKey.text = " [" + buyEvent.as_text_physical_keycode() + "]"
			break
	return

func showShop(shop: Shop) -> void:
	if shop.global_position.distance_to(Global.player.global_position) > _maxDistanceFromPlayer:
		_currentShop = null
		_buyPanelContainer.hide()
		return
		
	_currentShop = shop
	
	_buyPanelContainer.show()
	updateCost(shop.cost)
	
	# update container to fit under creature
	var screenPotision = Global.camera.unproject_position(shop.global_position) + Vector2(20, -40)
	_buyPanelContainer.position = screenPotision
	return
	
func tryToBuyItem() -> void:
	if _currentShop == null:
		Global.uiError.showError("No nearby shop to buy from!")
		return
	
	if _currentShop.cost > Global.coinCount:
		Global.uiError.showError("Not enough coins to buy item!")
		return
	
	if _currentShop.itemType == Global.ItemType.POTION:
		Global.potionCount += 1
		Global.coinCount -= _currentShop.cost
	
	if _currentShop.itemType == Global.ItemType.CAPTURE:
		Global.captureCount += 1
		Global.coinCount -= _currentShop.cost
		
	Global.uiHotkeys.updateQuantities(Global.captureCount, Global.potionCount, Global.coinCount)
		
	return
