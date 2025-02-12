extends Control

# The CollectionRow will be placed on the board and collect birds
# when placed on the far left or far right

# When placed on the left scan left to right, at the first instance of the same 
# card, move all cards into the players hand (Oppisite for right side)
# If non of the same card is found, allow the player to draw
@onready var row = $Row

var leftCard: Object = null
var rightCard: Object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if leftCard != null and Input.is_action_just_released("Grab"):
		# Use curCard as when the original is reparent is triggers 
		# the area exit, resetting it
		var curCard = leftCard
		
		var i: int = 0
		while (i < Global.cardsInHand.size()):
			var c = Global.cardsInHand[i]

			if c.data.id == curCard.data.id:
				# Remove from cardsInHand array
				Global.cardsInHand.remove_at(i)

				# Reparent cards control parent to CollectionRow
				c.get_parent().reparent(row)
				row.move_child(c.get_parent(),1)
				c.position = Vector2(0,0)

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
				# Remove from cardsInHand array
				Global.cardsInHand.remove_at(i)

				# Reparent cards control parent to CollectionRow
				c.get_parent().reparent(row)
				row.move_child(c.get_parent(),-2)
				c.position = Vector2(0,0)
				
				# Since we remove an element from the array, subtract 1 from index
				i -= 1
			i += 1
		# Ensure rightCard is reset
		rightCard = null


func _on_left_area_2d_area_entered(_area):
	print("Left Detected")
	leftCard = Global.isHolding

func _on_left_area_2d_area_exited(_area):
	leftCard = null

func _on_right_area_2d_area_entered(_area):
	print("Right Detected")
	rightCard = Global.isHolding


func _on_right_area_2d_area_exited(area):
	rightCard = null



