extends State

@export var wait: State
@export var endRound: State

@onready var unlock_sound = $UnlockSound

signal noCardsToFlyHome

func stateActive():
	super()
	var flyHomeIdsDict: Dictionary = Global.canFlyHome()
	var flyHomeSmallIds: Array = flyHomeIdsDict["small"]
	var flyHomeLargeIds: Array = flyHomeIdsDict["large"]
	if flyHomeSmallIds.is_empty() and flyHomeLargeIds.is_empty():
		noCardsToFlyHome.emit()
	else:
		var smallFlyHomeCards: Array[Object] = Global.getCardTypeInHand(flyHomeSmallIds)
		for card: BaseCard in smallFlyHomeCards:
			card.updateBorderColour(card.smallBorderColor)
		var largeFlyHomeCards: Array[Object] = Global.getCardTypeInHand(flyHomeLargeIds)
		for card: BaseCard in largeFlyHomeCards:
			card.updateBorderColour(card.largeBorderColor)
			
		unlock_sound.play()

func _nextState() -> State:
	if Global.cardsInHand.size() == 0:
		print("\nEMPTY HAND SO TRIGGER END ROUND\n")
		return endRound
	for card: BaseCard in Global.cardsInHand:
		card.updateBorderColour(card.defaultBorderColor)
	return wait
