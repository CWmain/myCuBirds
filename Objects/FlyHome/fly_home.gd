extends Control

@export var myHand: Hand
@export var myDeck: Deck
@onready var indicator = $Indicator
@onready var lock_image = $LockImage

@onready var fly_home_sound = $FlyHomeSound

var cardHeld: Object = null

var locked: bool = false
signal flownHome
# Called when the node enters the scene tree for the first time.
func _ready():
	assert(myHand != null)
	assert(myDeck != null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# If locked do nothing
	if locked:
		return
		
	# A given player card is dragged and dropped onto the detector
	if cardHeld != null and Input.is_action_just_released("Grab"):
		# Check the count of the given id and if that is enough birds to fly home
		var pointsEarned:int = scoreFromBird(cardHeld)
		if (pointsEarned > 0):
			# Free all like cards
			#Create a local copy of array as we are deleting from cardsInHand
			var localCardsInHand: Array = Global.cardsInHand.duplicate()
			for c in localCardsInHand:
				if c.data.id == cardHeld.data.id:
					# Free the parent control and than itself while adding to discard pile
					myDeck.clientDiscardHand.rpc_id(1,var_to_str(c.data))
					myHand.removeCard(c)
					
			# Since cards are flown home emit
			get_parent().updatePoints.rpc(multiplayer.get_unique_id(), cardHeld.data.id, pointsEarned)
			fly_home_sound.pitch_scale = 0.9 + (0.2*randf())
			fly_home_sound.play()
			flownHome.emit()


## Get the score associated with the amount of birds flown home
## Returns 0 on fail, 1 on min met and 2 on max met
func scoreFromBird(scoreCard: Object) -> int:
	var cardCount: int = 0
	for c in Global.cardsInHand:
		if c.data.id == scoreCard.data.id:
			cardCount += 1
	if cardCount >= scoreCard.data.large:
		return 2
	if cardCount >= scoreCard.data.small:
		return 1
	return 0

func lockSelf():
	indicator.show()
	lock_image.show()
	locked = true
	
func unlockSelf():
	indicator.hide()
	lock_image.hide()
	locked = false

func _on_area_2d_area_entered(_area):
	cardHeld = Global.isHolding


func _on_area_2d_area_exited(_area):
	cardHeld = null
