extends State

@export var placeCard: State
signal endRound

func stateActive():
	super()
	endRound.emit()

func _nextState() -> State:
	return placeCard
