extends Control

class_name Deck

@export var localHand: Hand
@export var localBoard: Board

@export var cardTypes: Array[CustomCard]
@export var cardTypesCount: Array[int]
## var_to_str of custom_card
@export var cards: Array[String]
@export var discardPile: Array[String]

@onready var discard_count_display = $HBoxContainer/DiscardCountDisplay
@onready var card_count_display = $HBoxContainer/CardCountDisplay
@onready var cards_sync = $cardsSync

## A card which topCard gives once all cards are exhausted to prevent errors
## Should be find as endgame is triggered 
@export var failCard: CustomCard

var locked: bool = false
signal cardsDrawn
signal outOfCards
func _ready():
	assert(localHand != null, "Assign hand")
	assert(localBoard != null, "Assign board")
	# Only the host can modify the deck
	cards_sync.set_multiplayer_authority(1)
	
	# Generate all cardsToMake in a random array order
	if multiplayer.get_unique_id() == 1:
		generateCardArray()
	cards.shuffle()
	updateCardCount()
	print("Number of Starting Cards: %d" % cards.size() )

func generateCardArray():
	assert(cardTypes.size() == cardTypesCount.size(), "cardTypes and cardTypesCount size do not equal")
	for i in range(cardTypes.size()):
		for j in range(cardTypesCount[i]):
			cards.append(var_to_str(cardTypes[i]))
	print(cards)

@rpc("any_peer","call_local","reliable")
func drawCardsToHand(toDraw: int):
	assert(multiplayer.is_server(), "Attempting to draw cards on non-host")
	var sender_id: int = multiplayer.get_remote_sender_id()
	# Convert resource to string so it can be sent via rcp
	var drawnCards: Array[String] = []
	for i in range(toDraw):
		var attemptToAdd = topCard()
		drawnCards.append(attemptToAdd)

	print("%d: Am drawing cards" % sender_id)

	updateCardCount()
		
	addCardsToHand.rpc_id(sender_id, drawnCards)
	
# Called locally by the sender of the draw request
@rpc("authority","call_local","reliable")
func addCardsToHand(toAdd: Array):
	for card in toAdd:
		localHand.addCardFromResource(str_to_var(card))

func notEnoughCards():
	assert(cards.size() == 0, "Attempting we reshuffle discard into draw when non-empty")

	if discardPile.size() == 0:
		print("Trigger game over, winner is player with most points")
		outOfCards.emit()
		return
		
	# Reshuffle discard pile into draw pile
	for c in discardPile:
		cards.append(c)
	discardPile.clear()
	cards.shuffle()
	updateCardCount()

@rpc("authority", "call_local", "reliable")
func discardHand():
	var localCardInHand: Array[Object] = Global.cardsInHand.duplicate()
	for card in localCardInHand:
		# Remove from hand and add same card to discard pile
		discardCard(var_to_str(card.data))
		localHand.removeCard(card)

## discard hand to be used on clients, who call it on host
@rpc("any_peer","call_local","reliable")
func clientDiscardHand(cardToDiscard: String):
	assert(multiplayer.is_server(), "Attempting to call discard hand on client")
	discardCard(cardToDiscard)

## cardToDiscard is a var_to_str of a CustomCard
func discardCard(cardToDiscard: String):
	discardPile.append(cardToDiscard)
	updateCardCount()

# Called by the host and causes the game board to be set up
func setUpTable():
	# Layout 4 rows of 3 cards, each row must contain unique cards
	var startingBoard: Array = generateStartingBoard()
	populateBoard.rpc(startingBoard)
	# Give 8 birds to each player
	newRoundCards()
	# Draw 1 card and give the player the associated point
	for p in Global.PLAYERS:
		var scoreCard = topCard()
		get_parent().updatePoints.rpc(p, str_to_var(scoreCard).id, 1)
	updateCardCount()
	
# Generates a 4x3 board of cards drawn from the draw pile
func generateStartingBoard() -> Array:
	var i = 0
	var startingBoard: Array = []
	while i < 4:
		startingBoard.append([])
		var j = 0
		while j < 3:
			var curCard = topCard()
			if (startingBoard[i].has(curCard)):
				print("Card Already placed so skip")
				discardCard(curCard)
				continue
			startingBoard[i].append(curCard)
			j += 1
		i += 1
	return startingBoard
	
## poplulateBoard is passed an array of cards which it populates the board with
## startingBoard: 3 x 4 array containing CustomCard strings
@rpc("authority", "call_local", "reliable")
func populateBoard(startingBoard: Array):
	var allRows: Array = localBoard.getAllRows()

	for i in range(startingBoard.size()):
		for j in range(startingBoard[i].size()):
			allRows[i].addCardToBoard(startingBoard[i][j], allRows[i].RowSide.LEFT)

## Use this to access the deck
func topCard() -> String:
	var curCard = cards.pop_front()
	if curCard == null:
		notEnoughCards()
		curCard = cards.pop_front()
		if (curCard == null):
			print("Ran out of cards in deck")
			curCard = var_to_str(failCard)
		assert(curCard != null, "Ran out of cards making starting board")
	updateCardCount()
	return curCard

func newRoundCards():
	
	# Discard the hand and Draw 8 new cards for each player
	for p in Global.PLAYERS:
		# Discard current hand
		discardHand.rpc_id(p)
		# Convert resource to string so it can be sent via rcp
		var drawnCards: Array[String] = []
		for i in range(8):
			var attemptToAdd = topCard()
			drawnCards.append(attemptToAdd)

		print("%d: Am drawing %d cards" % [p, drawnCards.size()])

		updateCardCount()
			
		addCardsToHand.rpc_id(p, drawnCards)

## Host is called to draw cards for the user
func _on_draw_pressed():
	if !locked:
		drawCardsToHand.rpc_id(1, 2)
		lockSelf()
		cardsDrawn.emit()
	else:
		print("Deck Locked")

func updateCardCount():
	card_count_display.text = "Count: %d" % cards.size()
	discard_count_display.text = "Discard: %d" % discardPile.size()

func lockSelf():
	locked = true
	
func unlockSelf():
	locked = false

@rpc("any_peer","call_local","reliable")
func triggerNewRound():
	assert(multiplayer.is_server())
	newRoundCards()
