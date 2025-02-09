extends Node2D

@export var localHand: Hand
@export var cardsToMake: Dictionary
@export var cards: Array

@onready var card_count_display = $CardCountDisplay
@onready var cards_sync = $cardsSync

func _ready():
	assert(localHand != null)
	# Only the host can modify the deck
	cards_sync.set_multiplayer_authority(1)
	
	# Generate all cardsToMake in a random array order
	if multiplayer.get_unique_id() == 1:
		generateCardArray()

	card_count_display.text = "Count: %d" % cards.size()

func generateCardArray():
	for item in cardsToMake:
		for i in range(1,cardsToMake[item]):
			cards.append(item)

@rpc("any_peer","call_local","reliable")
func drawCards():
	var sender_id: int = multiplayer.get_remote_sender_id()
	var drawnCards: Array
	drawnCards.append(cards.pop_front())
	drawnCards.append(cards.pop_front())
	print("%d: Am drawing cards" % sender_id)
	
	addCardsToHand.rpc_id(sender_id, drawnCards)
	card_count_display.text = "Count: %d" % cards.size()
# Called locally by the sender of the draw request
@rpc("any_peer","call_local","reliable")
func addCardsToHand(toAdd: Array):
	for card in toAdd:
		localHand.addCard(load(card))

## Host is called to draw cards for the user
func _on_draw_pressed():
	drawCards.rpc_id(1)
