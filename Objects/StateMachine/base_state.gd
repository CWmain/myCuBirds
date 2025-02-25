extends Node
class_name State

# Add to list to unlock / lock nodes on use
@export var toLock: Array[Node]
@export var toUnlock: Array[Node]

# Assumes that the object has a signal nextState
@export var nextStateCause: Node

func _ready():
	assert(nextStateCause.has_signal("nextState"), "Given node does not have nextState")
	nextStateCause.nextState.connect(_nextState)

# Called when state is changed to adjust locks
func stateActive():
	for n in toLock:
		n.lockSelf()
		
	for n in toUnlock:
		n.unlockSelf()

func _nextState() -> State:
	assert(false, "Next State is unset")
	return self
