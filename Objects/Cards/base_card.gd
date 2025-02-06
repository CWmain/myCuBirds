extends Node2D

@export var data: CustomCard
@onready var label = $Label
@onready var icon = $Icon

func _ready():
	assert(data != null)
	
	icon.texture = load(data.image)
	label.text = str(data.small) + " / " + str(data.large)
