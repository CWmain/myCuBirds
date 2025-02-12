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

		var i: int = 0
		for c in Global.cardsInHand:

			if c.data.id == leftCard.data.id:
				var baseControl = Control.new()
				Global.cardsInHand.remove_at(i)
				c.reparent(baseControl)
				row.add_child(baseControl)
				row.move_child(baseControl,1)
				c.position = Vector2(0,0)
			i += 1
				
	if rightCard != null and Input.is_action_just_released("Grab"):
		var i: int = 0
		for c in Global.cardsInHand:
			if c.data.id == rightCard.data.id:
				var baseControl = Control.new()
				Global.cardsInHand.remove_at(i)
				c.reparent(baseControl)
				row.add_child(baseControl)
				row.move_child(baseControl,-2)
				c.position = Vector2(0,0)
			i += 1


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



