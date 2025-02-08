extends Node2D

class_name BaseCard

@export var data: CustomCard
@export var SPEED: float = 1200.0

@onready var label = $Label
@onready var icon = $Icon
@onready var color_rect = $ColorRect

var canGrab: bool = false
var isGrabbing: bool = false

var goHome: bool = false
## Home should always be (0,0) since the control determins location
var home: Vector2 = Vector2(0,0)

signal cardGrabbed
signal cardReleased

func _ready():
	assert(data != null)
	assert(FileAccess.file_exists(data.image))
	
	label.text = str(data.small) + " / " + str(data.large)
	icon.texture = load(data.image)

func _process(delta):
	# When a card is grabbed, free in from the hand
	if Input.is_action_pressed("Grab") and (canGrab or isGrabbing):
		for c in get_tree().get_nodes_in_group("card"):
			if c != self and data.id == c.data.id:
				c.position += get_global_mouse_position() - get_parent().global_position - position 
		position = get_global_mouse_position() - get_parent().global_position

		isGrabbing = true
		goHome = false
		
	if Input.is_action_just_released("Grab") and isGrabbing:
		cardReleased.emit()
		isGrabbing = false
		for c in get_tree().get_nodes_in_group("card"):
			c.goHome = true
	
	# Move card to home location
	if goHome:
		position += (home - position).normalized()*SPEED*delta
	if (home - position).length() < SPEED*delta:
		position = home
		goHome = false

func _on_color_rect_mouse_entered():
	color_rect.color = Color(1,1,1,1)
	canGrab = true

func _on_color_rect_mouse_exited():
	color_rect.color = Color(0,0,0,1)
	canGrab = false
