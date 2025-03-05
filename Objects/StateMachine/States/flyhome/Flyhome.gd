extends State

@export var wait: State
@export var endRound: State

func stateActive():
	super()
	

func _nextState() -> State:
	if Global.cardsInHand.size() == 0:
		print("\nEMPTY HAND SO TRIGGER END ROUND\n")
		return endRound
	return wait
