extends Control

@export var myDeck: Deck
var cardTypes: Array[CustomCard]

@onready var player_name = $PlayerName
@onready var grid_container = $GridContainer

var scoreTracker: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	cardTypes = myDeck.cardTypes
	for ct in cardTypes:
		scoreTracker[ct.id] = 0
		var l = Label.new()
		l.text = str(ct.id) + " : 0"
		grid_container.add_child(l)

func setOwnerText(s: String):
	player_name.text = "Owner: " + str(s)
	
## id: The id of the card collected
## points: Number of points to add
func addPoints(id: String, points: int):
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
