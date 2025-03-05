extends State

@export var wait: State
@export var endRound: State

signal noCardsToFlyHome

func stateActive():
	super()
	if !Global.canFlyHome():
		print("No birds to fly home")
		noCardsToFlyHome.emit()

func _nextState() -> State:
	if Global.cardsInHand.size() == 0:
		print("\nEMPTY HAND SO TRIGGER END ROUND\n")
		return endRound
	return wait
