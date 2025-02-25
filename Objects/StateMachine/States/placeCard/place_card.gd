extends State

@export var flyHome: State
@export var Draw2: State

func _nextState() -> State:
	print("State overide works for place")
	return self
