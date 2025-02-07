extends Node2D

@onready var fla = $Fla
@onready var owl = $Owl


func _ready():
	owl.home = Vector2(400,400)

func _process(delta):
	if multiplayer.is_server():
		print("%d I am server" % multiplayer.get_unique_id())
	else:
		print("%d I am client" % multiplayer.get_unique_id())
	print(get_multiplayer_authority())
