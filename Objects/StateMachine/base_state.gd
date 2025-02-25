extends Node
class_name State

# Add to list to unlock / lock nodes on use
@export var toLock: Array[Node]
@export var toUnlock: Array[Node]


# Called when state is changed to adjust locks
func stateActive():
	for n in toLock:
		n.lockSelf()
		
	for n in toUnlock:
		n.unlockSelf()

func _nextState() -> State:
	assert(false, "Next State is unset")
	return self
