extends Node2D

@export var localHand: Hand
@export var cardsToMake: Dictionary
@export var cards: Array

@onready var card_count_display = $CardCountDisplay
@onready var cards_sync = $cardsSync

var locked: bool = false

func _ready():
	assert(localHand != null)
	# Only the host can modify the deck
	cards_sync.set_multiplayer_authority(1)
	
	# Generate all cardsToMake in a random array order
	if multiplayer.get_unique_id() == 1:
		generateCardArray()
	cards.shuffle()
	card_count_display.text = "Count: %d" % cards.size()

func generateCardArray():
	for item in cardsToMake:
		for i in range(cardsToMake[item]):
			cards.append(item)

@rpc("any_peer","call_local","reliable")
func drawCards(toDraw: int):
	assert(multiplayer.get_unique_id() == 1, "Attempting to draw cards on non-host")
	var sender_id: int = multiplayer.get_remote_sender_id()
	var drawnCards: Array[String] = []
	for i in range(toDraw):
		var attemptToAdd = cards.pop_front()
		if attemptToAdd == null:
			notEnoughCards()
			return
		drawnCards.append(attemptToAdd)

	print("%d: Am drawing cards" % sender_id)
	print(drawnCards)
	card_count_display.text = "Count: %d" % cards.size()
		
	addCardsToHand.rpc_id(sender_id, drawnCards)
	
# Called locally by the sender of the draw request
@rpc("any_peer","call_local","reliable")
func addCardsToHand(toAdd: Array):
	for card in toAdd:
		localHand.addCard(load(card))

func notEnoughCards():
	print("Not Enough Cards in Deck!!!")

## Host is called to draw cards for the user
func _on_draw_pressed():
	if !locked:
		drawCards.rpc_id(1, 2)
	else:
		print("Deck Locked")

func lockDeck():
	locked = true
	
func unlockDeck():
	locked = false
