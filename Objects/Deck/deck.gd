extends Control

@export var localHand: Hand
@export var cardTypes: Array[CustomCard]
@export var cardTypesCount: Array[int]
@export var cards: Array[String]
@export var discardPile: Array[String]

@onready var card_count_display = $CardCountDisplay
@onready var cards_sync = $cardsSync

var locked: bool = false
signal cardsDrawn

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
	assert(cardTypes.size() == cardTypesCount.size(), "cardTypes and cardTypesCount size do not equal")
	for i in range(cardTypes.size()):
		for j in range(cardTypesCount[i]):
			cards.append(var_to_str(cardTypes[i]))
	print(cards)

@rpc("any_peer","call_local","reliable")
func drawCards(toDraw: int):
	assert(multiplayer.get_unique_id() == 1, "Attempting to draw cards on non-host")
	var sender_id: int = multiplayer.get_remote_sender_id()
	# Convert resource to string so it can be sent via rcp
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
		localHand.addCardFromResource(str_to_var(card))

func notEnoughCards():
	print("Not Enough Cards in Deck!!!")

## Host is called to draw cards for the user
func _on_draw_pressed():
	if !locked:
		drawCards.rpc_id(1, 2)
		lockDeck()
		cardsDrawn.emit()
	else:
		print("Deck Locked")

func lockDeck():
	locked = true
	
func unlockDeck():
	locked = false
