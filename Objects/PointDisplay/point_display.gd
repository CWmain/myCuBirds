extends Control

@export var cardTypes: Array[CustomCard]

@onready var grid_container = $GridContainer

var scoreTracker: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	for ct in cardTypes:
		scoreTracker[ct.id] = 0
		var l = Label.new()
		l.text = str(ct.id) + " : 0"
		grid_container.add_child(l)
		

func addPoints(id: String, points: int):
	print(str(scoreTracker) + " " + id)
	print(scoreTracker.has(id))
	assert(scoreTracker.has(id))
	scoreTracker[id] += points
	
	# Scan thru cardTypes to find the index of the correct label
	# and update its display
	var gridIndex: int = 0
	for ct in cardTypes:
		if ct.id == id:
			var labelToEdit = grid_container.get_child(gridIndex)
			labelToEdit.text = id + " : " + str(scoreTracker[id])
		gridIndex += 1
