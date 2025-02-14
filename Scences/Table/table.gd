extends Control

@onready var all_points = $AllPoints
@onready var hand = $Hand

@onready var label = $Label

var idToLabel: Dictionary
var pointsDisplay = preload("res://Objects/PointDisplay/point_display.tscn")

## The mutiplayer id of the person whos turn it is
@export var playerTurn: int = 1:
	set(value):
		playerTurn = value
		label.text = str(value)
var playerTurnIndex: int = 0

func _ready():
	if multiplayer.is_server():
		print("Is host")
	else:
		print("Is client")
	
	for p in Global.PLAYERS:
		idToLabel[p] = pointsDisplay.instantiate()
		all_points.add_child(idToLabel[p])
		idToLabel[p].setOwnerText(str(p))


func _process(_delta):
	pass

@rpc("any_peer", "call_local", "reliable")
func nextTurn():
	assert(multiplayer.get_unique_id() == 1, "Non-Host attempted to start next turn")
	playerTurnIndex += 1
	if playerTurnIndex >= Global.PLAYERS.size():
		playerTurnIndex = 0
	playerTurn = Global.PLAYERS[playerTurnIndex]
	startTurn.rpc_id(playerTurn)

@rpc("any_peer", "call_local", "reliable")
func startTurn():
	print("Allow %s to place birds on board" % str(multiplayer.get_unique_id()))
	hand.unlockHand()	

@rpc("any_peer", "call_local")
func updatePoints(uid: int, cid: String, p: int):
	assert(idToLabel.has(uid), str(idToLabel))
	idToLabel[uid].addPoints(cid, p)
	
func _on_button_pressed():
	hand.lockHand()
	nextTurn.rpc_id(1)


func _on_board_birds_placed(birdsCollected: bool):
	print("Birds Collected: %s" % str(birdsCollected))
