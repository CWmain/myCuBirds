extends Control

@export var myHand: Hand
@onready var indicator = $Indicator
var cardHeld: Object = null
# Called when the node enters the scene tree for the first time.
func _ready():
	assert(myHand != null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# A given player card is dragged and dropped onto the detector
	if cardHeld != null and Input.is_action_just_released("Grab"):
		# Check the count of the given id and if that is enough birds to fly home
		
		# Free all like cards 
		for c in get_tree().get_nodes_in_group("card"):
			if c.data.id == cardHeld.data.id:
				# Free the parent control and than itself
				c.get_parent().queue_free()
				c.queue_free()

func _on_area_2d_area_entered(area):
	indicator.color = Color(0,0,0,1)
	cardHeld = Global.isHolding


func _on_area_2d_area_exited(area):
	indicator.color = Color(1,1,1,1)
	cardHeld = null
