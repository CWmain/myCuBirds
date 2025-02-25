extends State

@export var place: State


func _nextState() -> State:
	print("State overide works")
	return place
