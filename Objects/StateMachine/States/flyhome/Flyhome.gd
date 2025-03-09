extends State

@export var wait: State
@export var endRound: State

signal noCardsToFlyHome

func stateActive():
	super()
	var flyHomeIds: Array[String] = Global.canFlyHome()
	if flyHomeIds.is_empty():
		noCardsToFlyHome.emit()
	else:
		var flyHomeCards: Array[Object] = Global.getCardTypeInHand(flyHomeIds)
		for card: BaseCard in flyHomeCards:
			card.updateBorderColour(card.highlightBorderColor)

func _nextState() -> State:
	if Global.cardsInHand.size() == 0:
		print("\nEMPTY HAND SO TRIGGER END ROUND\n")
		return endRound
	for card: BaseCard in Global.cardsInHand:
		card.updateBorderColour(card.defaultBorderColor)
	return wait
