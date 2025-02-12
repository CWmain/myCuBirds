extends Control

@onready var all_points = $AllPoints
@onready var hand = $Hand

var idToLabel: Dictionary
var pointsDisplay = preload("res://Objects/PointDisplay/point_display.tscn")

func _ready():
	if multiplayer.is_server():
		print("Is host")
	else:
		print("Is client")
	
	idToLabel[multiplayer.get_unique_id()] = pointsDisplay.instantiate()
	all_points.add_child(idToLabel[multiplayer.get_unique_id()])
	idToLabel[multiplayer.get_unique_id()].setOwnerText(str(multiplayer.get_unique_id()))
	for p in Global.PLAYERS:
		idToLabel[p] = pointsDisplay.instantiate()
		all_points.add_child(idToLabel[p])
		idToLabel[p].setOwnerText(str(p))

func _process(_delta):
	pass

@rpc("any_peer", "call_local")
func updatePoints(uid: int, cid: String, p: int):
	assert(idToLabel.has(uid), str(idToLabel))
	idToLabel[uid].addPoints(cid, p)
	
