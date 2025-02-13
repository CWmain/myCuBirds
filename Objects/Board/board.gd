extends Control

# The host will have full authority over the board
# Clients will send requests to the rows of what cards they are adding, and the 
# host will respond with what cards they have collected, than removes those cards
# from the board
@export var MAX_SEP: int = 128
@export var MIN_SEP: int = 0
@export var CARD_SCALE: float = 0.15

@onready var v_box_container = $VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Only the host can edit the board
	for row in v_box_container.get_children():
		row.MAX_SEP = MAX_SEP
		row.MIN_SEP = MIN_SEP
		row.CARD_SCALE = CARD_SCALE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
