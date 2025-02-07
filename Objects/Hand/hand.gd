extends Node2D

@onready var card_movement_sync = $CardMovementSync
@onready var base_card = $BaseCard

var id: int = 0
@export var newHome: Vector2 = Vector2.ZERO
@export var tname: String = "default"

func _ready():
	base_card.home = newHome

func _process(delta):
	if get_multiplayer_authority() == multiplayer.get_unique_id():

		if Input.is_action_pressed("Grab") and (base_card.canGrab or base_card.isGrabbing):
			base_card.position = to_local(get_global_mouse_position())
			base_card.isGrabbing = true
			base_card.goHome = false
			
		if Input.is_action_just_released("Grab") and base_card.isGrabbing:
			base_card.isGrabbing = false
			base_card.goHome = true
	
	# Move card to home location
	if base_card.goHome:
		base_card.position += (base_card.home - to_global(base_card.position)).normalized()*base_card.SPEED*delta
	if (base_card.home - to_global(base_card.position)).length() < base_card.SPEED*delta:
		base_card.position = to_local(base_card.home)
		base_card.goHome = false
		
