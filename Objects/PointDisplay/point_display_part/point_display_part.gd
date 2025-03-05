extends HBoxContainer

class_name PDP

@onready var texture_rect = $TextureRect
@onready var score_display = $ScoreDisplay

@export var img: Texture:
	set = set_img
@export var score: int:
	set = set_score

func _ready():
	assert(img != null)
	set_img(img)
	set_score(0)

func set_score(value: int):
	score = value
	if score_display != null:
		score_display.text = str(value)

func set_img(value: Texture):
	img = value
	
	if texture_rect != null:
		texture_rect.texture = value
