extends Control

class_name Board

# The host will have full authority over the board
# Clients will send requests to the rows of what cards they are adding, and the 
# host will respond with what cards they have collected, than removes those cards
# from the board
@export var MAX_SEP: int = 128
@export var MIN_SEP: int = 0
@export var margin: int = 0
@export var CARD_SCALE: float = 0.15
@export var myHand: Hand
@export var myDeck: Deck
@onready var v_box_container = $VBoxContainer

signal birdsPlaced(birdsCollected: bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(myHand != null, "Hand not assigned on Board")
	assert(myDeck != null, "Deck not assinged on Board")
	# Only the host can edit the board
	for row in v_box_container.get_children():
		row.MAX_SEP = MAX_SEP
		row.MIN_SEP = MIN_SEP
		row.CARD_SCALE = CARD_SCALE
		row.myHand = myHand
		row.myDeck = myDeck
		row.locked = false
		row.margin = margin
		row.birdsPlaced.connect(_on_birds_placed)

# Pass the signal up from any row
func _on_birds_placed(birdsCollected: bool):
	birdsPlaced.emit(birdsCollected)
	
func lockSelf():
	for row in v_box_container.get_children():
		row.locked = true
		
func unlockSelf():
	for row in v_box_container.get_children():
		row.locked = false

func getAllRows() -> Array:
	return v_box_container.get_children()
