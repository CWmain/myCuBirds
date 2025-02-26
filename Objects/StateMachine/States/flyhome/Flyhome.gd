extends State

@export var wait: State

func _nextState() -> State:
	return wait
