extends Node2D

@export var data: CustomCard
@export var SPEED: float = 1200.0

@onready var label = $Label
@onready var icon = $Icon
@onready var color_rect = $ColorRect

var canGrab: bool = false
var isGrabbing: bool = false

var goHome: bool = false
var home: Vector2 = Vector2(0,0)

func _ready():
	assert(data != null)
	assert(FileAccess.file_exists(data.image))
	
	label.text = str(data.small) + " / " + str(data.large)
	icon.texture = load(data.image)

func _process(_delta):
	pass


func _on_color_rect_mouse_entered():
	color_rect.color = Color(1,1,1,1)
	canGrab = true

func _on_color_rect_mouse_exited():
	color_rect.color = Color(0,0,0,1)
	canGrab = false
