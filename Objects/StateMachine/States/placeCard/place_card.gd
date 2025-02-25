extends State

@export var flyHome: State
@export var Draw2: State

var birdsCollected: bool


func _birdState(value: bool) -> State:
	birdsCollected = value
	return _nextState()

func _nextState() -> State:
	if birdsCollected:
		print("Flyhome")
		return flyHome
	else:
		print("Draw2")
		return Draw2
