extends Node2D

@onready var fla = $Fla
@onready var owl = $Owl

func _ready():
	owl.home = Vector2(400,400)
