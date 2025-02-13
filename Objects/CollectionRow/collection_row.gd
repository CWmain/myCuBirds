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
@export var CARD_SCALE: float = 0.2
@export var myHand: Hand

@onready var row = $Row
var leftCard: Object = null
var rightCard: Object = null

enum RowSide {
	RIGHT,
	LEFT
}

# Called when the node enters the scene tree for the first time.
func _ready():
	row.add_theme_constant_override("separation", MAX_SEP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var windowSize: Vector2 = Vector2(DisplayServer.window_get_size())
	var currentSeparation: int = row.get_theme_constant("separation")

	# The added Vector is due to cards being centered, so this gives some extra magin
	if (row.size+Vector2(256,256) > windowSize and currentSeparation > MIN_SEP):
		row.add_theme_constant_override("separation", currentSeparation-1)
		currentSeparation -= 1
	if (row.size+Vector2(256,256) < windowSize and currentSeparation < MAX_SEP):
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
		# Ensure rightCard is reset
		rightCard = null

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
		
	# Create list of cards to collect
	
	# Delete those cards from all boards
	
	# Add those cards to the callers hand
		
	
func _on_left_area_2d_area_entered(_area):
	print("Left Detected")
	leftCard = Global.isHolding

func _on_left_area_2d_area_exited(_area):
	leftCard = null

func _on_right_area_2d_area_entered(_area):
	print("Right Detected")
	rightCard = Global.isHolding


func _on_right_area_2d_area_exited(_area):
	rightCard = null



