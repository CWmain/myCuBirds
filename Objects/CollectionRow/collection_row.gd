extends Control

# The CollectionRow will be placed on the board and collect birds
# when placed on the far left or far right

# When placed on the left scan left to right, at the first instance of the same 
# card, move all cards into the players hand (Oppisite for right side)
# If non of the same card is found, allow the player to draw
const BASE_CARD = preload("res://Objects/Cards/base_card.tscn")

@export var MAX_SEP: int = 128:
	set(value):
		MAX_SEP = value
		row.add_theme_constant_override("separation", MAX_SEP)
@export var MIN_SEP: int = 0
@export var margin: int = 0

@export var CARD_SCALE: float = 0.2
@export var myHand: Hand
@export var myDeck: Deck
@onready var row = $"."

var leftCard: Object = null
var rightCard: Object = null

var locked: bool = false

## birdCollected informs if player collected cards from the board
signal birdsPlaced(birdsCollected: bool)

enum RowSide {
	RIGHT,
	LEFT
}

# Called when the node enters the scene tree for the first time.
func _ready():
	row.add_theme_constant_override("separation", MAX_SEP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var windowWidth: float = Vector2(DisplayServer.window_get_size()).x
	var currentSeparation: int = row.get_theme_constant("separation")

	# The added Vector is due to cards being centered, so this gives some extra magin
	if (row.size.x+margin > windowWidth and currentSeparation > MIN_SEP):
		row.add_theme_constant_override("separation", currentSeparation-1)
		currentSeparation -= 1
	if (row.size.x+margin < windowWidth and currentSeparation < MAX_SEP):
		row.add_theme_constant_override("separation", currentSeparation+1)
	
	if leftCard != null and Input.is_action_just_released("Grab"):
		# Use curCard as when the original is reparent is triggers 
		# the area exit, resetting it
		var curCard = leftCard
		
		var i: int = 0
		while (i < Global.cardsInHand.size()):
			var c = Global.cardsInHand[i]

			if c.data.id == curCard.data.id:
				# Reconstructs the given card onto all boards
				addCardToBoard.rpc(var_to_str(c.data), RowSide.LEFT)
				
				# Deletes the old card from hand
				myHand.removeCard(c)
				# Since we remove an element from the array, subtract 1 from index
				i -= 1
			i += 1
		collectBirds(curCard.data.id)
		
		# Ensure leftCard is reset
		leftCard = null
				
	if rightCard != null and Input.is_action_just_released("Grab"):
		# Use curCard as when the original is reparent is triggers 
		# the area exit, resetting it
		var curCard = rightCard
		
		var i: int = 0
		while (i < Global.cardsInHand.size()):
			var c = Global.cardsInHand[i]

			if c.data.id == curCard.data.id:				
				# Reconstructs the given card onto all boards
				addCardToBoard.rpc(var_to_str(c.data), RowSide.RIGHT)
				
				# Deletes the old card from hand
				myHand.removeCard(c)
				
				# Since we remove an element from the array, subtract 1 from index
				i -= 1
			i += 1
		
		collectBirds(curCard.data.id)
		
		# Ensure rightCard is reset
		rightCard = null

	if multiplayer.is_server() and allBirdsInRowSame():
		var drawnCard: String = myDeck.topCard()
		addCardToBoard.rpc(drawnCard, RowSide.RIGHT)
		
func collectBirds(cid: String):
	var birdsToCollect: Array[int] = findBirdsToCollect(cid)
	for index in birdsToCollect:
		moveBoardCardToHand(index)
		removeBoardCard.rpc(index)
		
	birdsPlaced.emit(birdsToCollect.size() > 0)

func sort_descending(a, b):
	if a > b:
		return true
	return false	

func findBirdsToCollect(cid: String) -> Array[int]:
	var toCollect: Array[int] = []
	var index: int = 0
	var rowChildren = row.get_children()
	var firstInstance: bool = false
	var startCounting: bool = false
	var endFound: bool = false
	for childControl in rowChildren:
		if index == 0 or index == rowChildren.size()-1:
			index += 1
			continue
		
		# First instance of cid found, next not matching we start counting
		if !firstInstance and childControl.get_child(0).data.id == cid:
			firstInstance = true
		
		# We have started counting and the end is found
		if startCounting and childControl.get_child(0).data.id == cid:
			endFound = true
			break
		
		# Already found the first instance and will start counting	
		if firstInstance and childControl.get_child(0).data.id != cid:
			startCounting = true
			toCollect.append(index)
			
		index += 1
	# Return an empty array if the right side does not have another instance
	if !endFound:
		return []
	toCollect.sort_custom(sort_descending)
	return toCollect
		
# Passed the var_to_str(customCard)
## Constructs new bird cards on collection row
@rpc("any_peer","call_local","reliable")
func addCardToBoard(cardDataString: String, side: RowSide):
	# Ensure card data is passed correctly
	var cardData = str_to_var(cardDataString)
	assert(cardData is CustomCard, "cardDataString was not CustomCard Resource")
	
	# Construct the new card
	var newCard = BASE_CARD.instantiate()
	newCard.data = cardData
	newCard.scale = Vector2(CARD_SCALE, CARD_SCALE)
	newCard.isActive = false
	
	# Place the card on the given side
	var pc = Control.new()
	pc.add_child(newCard)
	row.add_child(pc)
	if (side == RowSide.LEFT):
		row.move_child(pc,1)
	elif (side == RowSide.RIGHT):
		row.move_child(pc,-2)
	else:
		assert(false, "Invalid Side Given")

# NOTE: call_remote so it is only applied to others
## cardToRemove: The child index of the given card
@rpc("any_peer","call_remote","reliable")
func removeBoardCard(cardToRemove: int):
	var curCard = row.get_children()[cardToRemove].get_child(0)
	row.get_children()[cardToRemove].queue_free()
	curCard.queue_free()
	
## cardToMove: The child index of the given card
func moveBoardCardToHand(cardToMove: int):
	var curCard = row.get_children()[cardToMove].get_child(0)
	myHand.addCardFromResource(curCard.data)
	row.get_children()[cardToMove].queue_free()
	curCard.queue_free()

func allBirdsInRowSame() -> bool:
	var rowChildren: Array = row.get_children()
	var prev: String = "unset"
	for childControl in rowChildren:
		if !(childControl.get_child(0) is BaseCard):
			continue
		if prev == "unset":
			prev = childControl.get_child(0).data.id
			continue
		if childControl.get_child(0).data.id != prev:
			return false
			
	return true


func _on_left_area_2d_area_entered(_area):
	if locked:
		return
	print("Left Detected")
	leftCard = Global.isHolding

func _on_left_area_2d_area_exited(_area):
	leftCard = null

func _on_right_area_2d_area_entered(_area):
	if locked:
		return
	print("Right Detected")
	rightCard = Global.isHolding

func _on_right_area_2d_area_exited(_area):
	rightCard = null



