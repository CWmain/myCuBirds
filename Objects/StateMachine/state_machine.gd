extends Node
class_name StateMachine

@export var states: Dictionary
@export var curState: State:
	set(value):
		curState = value
		curState.stateActive()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Append all states to a state dicitonary
	for child in get_children():
		# Skip non-state children
		if (!(child is State)):
			continue
		states[child.name] = child


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
