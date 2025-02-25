extends State

@export var flyHome: State
@export var Draw2: State

var birdsCollected: bool

func _ready():
	nextStateCause.birdsPlaced.connect(_birdState)

func _birdState(value: bool):
	birdsCollected = value
	_nextState()

func _nextState() -> State:
	if birdsCollected:
		print("Flyhome")
		return flyHome
	else:
		print("Draw2")
		return Draw2
