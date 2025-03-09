extends Node2D

class_name BaseCard

@export var data: CustomCard
@export var defaultBorderColor: Color
@export var highlightBorderColor: Color
@export var SPEED: float = 1200.0
@export var liftHeight: float = 30

@onready var label = $Label
@onready var icon = $Icon
@onready var color_rect = $ColorRect
@onready var area_2d = $Area2D
@onready var border = $Border

var canGrab: bool = false
var isGrabbing: bool = false

var goHome: bool = false
## Home should always be (0,0) since the control determins location
var home: Vector2 = Vector2(0,0)

var isActive: bool = true

signal cardGrabbed
signal cardReleased

func _ready():
	assert(data != null)
	label.text = str(data.small) + " / " + str(data.large)
	assert(data.image != null)
	icon.texture = data.image
	
	updateBorderColour(defaultBorderColor)

func _process(delta):
	# If card is inactive do nothing
	if !isActive:
		return
	var handIsFreeOrHolding = Global.isHolding == null or Global.isHolding == self
	# When a card is grabbed, free in from the hand
	if Input.is_action_pressed("Grab") and (canGrab or isGrabbing) and handIsFreeOrHolding:
		Global.isHolding = self
		area_2d.monitorable = true
		var cardOffset: Vector2 = Vector2(32,0)
		var affectedCards: int = 1
		var newPosition: Vector2 = get_global_mouse_position()
		# Adjust the location of same named cards the same amount as the moved card
		for c in Global.cardsInHand:
			if c != self and data.id == c.data.id:
				c.goHome = false
				c.position = newPosition - c.get_parent().global_position + (cardOffset*affectedCards)
				affectedCards += 1
				 
		position = get_global_mouse_position() - get_parent().global_position
	
		isGrabbing = true
		goHome = false
		
	if Input.is_action_just_released("Grab") and isGrabbing:
		Global.isHolding = null
		area_2d.monitorable = false
		cardReleased.emit()
		isGrabbing = false
		# Set all cards with same id to goHome
		for c in get_tree().get_nodes_in_group("card"):
			c.goHome = true
	
	# Move card to home location
	if goHome:
		position += (home - position).normalized()*SPEED*delta
	if (home - position).length() < SPEED*delta:
		position = home
		goHome = false

func _on_color_rect_mouse_entered():
	# Hover affect
	if isActive and !isGrabbing:
		#position.y = - liftHeight
		z_index = 1
		for c in Global.getCardTypeInHand([data.id]):
			c.position.y = -liftHeight
		
	color_rect.color = Color(1,1,1,1)
	canGrab = true

func _on_color_rect_mouse_exited():
	if isActive and !isGrabbing:
		#position.y = 0
		z_index = 0
		for c in Global.getCardTypeInHand([data.id]):
			c.position.y = 0
	color_rect.color = Color(0,0,0,1)
	canGrab = false

func updateBorderColour(col: Color):
	border.color = col
