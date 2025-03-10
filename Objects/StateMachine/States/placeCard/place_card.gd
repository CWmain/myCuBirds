extends State

@export var flyHome: State
@export var Draw2: State

@onready var card_place_sound = $cardPlaceSound

var birdsCollected: bool


func _birdState(value: bool) -> State:
	birdsCollected = value
	return _nextState()

func _nextState() -> State:
	# Randomly shifts pitch between 0.9 and 1.1
	card_place_sound.pitch_scale = 0.9 + (0.2*randf())
	card_place_sound.play()
	if birdsCollected:
		print("Flyhome")
		return flyHome
	else:
		print("Draw2")
		return Draw2
