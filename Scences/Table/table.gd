extends Node2D

@onready var my_points = $MyPoints
@onready var their_points = $TheirPoints

var idToLabel: Dictionary
@onready var all_points = $AllPoints

@onready var ui = $UI
@onready var hand = $UI/Hand

var points: int = 0

func _ready():
	if multiplayer.is_server():
		print("Is host")
	else:
		print("Is client")
	
	for p in Global.PLAYERS:
		idToLabel[p] = Label.new()
		idToLabel[p].text = str(p)
		all_points.add_child(idToLabel[p])
	
	# The UI control node is set to be the same size as the window to align UI elements
	ui.size = DisplayServer.window_get_size()
	get_tree().get_root().size_changed.connect(_on_resize)

func _process(_delta):
	if (hand.container.size > ui.size):
		hand.cardScale -= 0.01 
	
func _on_button_pressed():
	points += 1
	my_points.text = str(points)
	updatePoints.rpc(multiplayer.get_unique_id(), points)

func _on_resize():
	ui.size = DisplayServer.window_get_size()
	hand.cardScale = 0.2
	
	print("%s : %s" % [str(ui.size), str(hand.container.size)])

@rpc("any_peer", "call_remote")
func updatePoints(id: int, p: int):
	idToLabel[id].text = "%d: %d" % [id, p]
	
