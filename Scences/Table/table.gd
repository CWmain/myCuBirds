extends Node2D

@onready var my_points = $MyPoints
@onready var their_points = $TheirPoints

var idToLabel: Dictionary
@onready var all_points = $AllPoints

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
		


func _process(delta):
	pass
	
func _on_button_pressed():
	points += 1
	my_points.text = str(points)
	updatePoints.rpc(multiplayer.get_unique_id(), points)

@rpc("any_peer", "call_remote")
func updatePoints(id: int, p: int):
	idToLabel[id].text = "%d: %d" % [id, p]
	
