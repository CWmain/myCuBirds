extends Control

@export var localHand: Hand
@export var localBoard: Board

@export var cardTypes: Array[CustomCard]
@export var cardTypesCount: Array[int]
@export var cards: Array[String]
@export var discardPile: Array[String]

@onready var card_count_display = $CardCountDisplay
@onready var cards_sync = $cardsSync

var locked: bool = false
signal cardsDrawn

func _ready():
	assert(localHand != null, "Assign hand")
	assert(localBoard != null, "Assign board")
	# Only the host can modify the deck
	cards_sync.set_multiplayer_authority(1)
	
	# Generate all cardsToMake in a random array order
	if multiplayer.get_unique_id() == 1:
		generateCardArray()
	cards.shuffle()
	card_count_display.text = "Count: %d" % cards.size()
	if multiplayer.is_server():
		setUpTable()

func generateCardArray():
	assert(cardTypes.size() == cardTypesCount.size(), "cardTypes and cardTypesCount size do not equal")
	for i in range(cardTypes.size()):
		for j in range(cardTypesCount[i]):
			cards.append(var_to_str(cardTypes[i]))
	print(cards)

@rpc("any_peer","call_local","reliable")
func drawCardsToHand(toDraw: int):
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

	card_count_display.text = "Count: %d" % cards.size()
		
	addCardsToHand.rpc_id(sender_id, drawnCards)
	
# Called locally by the sender of the draw request
@rpc("any_peer","call_local","reliable")
func addCardsToHand(toAdd: Array):
	for card in toAdd:
		localHand.addCardFromResource(str_to_var(card))

func notEnoughCards():
	print("Not Enough Cards in Deck!!!")

## cardToDiscard is a var_to_str of a CustomCard
func discardCard(cardToDiscard: String):
	discardPile.append(cardToDiscard)

# Called by the host and causes the game board to be set up
func setUpTable():
	# Layout 4 rows of 3 cards, each row must contain unique cards
	var startingBoard: Array = generateStartingBoard()
	populateBoard.rpc(startingBoard)
	card_count_display.text = "Count: %d" % cards.size()
	# Give 8 birds to each player
	
	# Draw 1 card and give the player the associated point

# Generates a 4x3 board of cards drawn from the draw pile
func generateStartingBoard() -> Array:
	var i = 0
	var startingBoard: Array
	while i < 4:
		startingBoard.append([])
		var j = 0
		while j < 3:
			var curCard = cards.pop_front()
			if curCard == null:
				notEnoughCards()
				assert(false, "Ran out of cards making starting board")
			if (startingBoard[i].has(curCard)):
				print("Card Already placed so skip")
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

## Host is called to draw cards for the user
func _on_draw_pressed():
	if !locked:
		drawCardsToHand.rpc_id(1, 2)
		lockDeck()
		cardsDrawn.emit()
	else:
		print("Deck Locked")

func lockDeck():
	locked = true
	
func unlockDeck():
	locked = false
