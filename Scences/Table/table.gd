extends Control

@onready var all_points = $AllPoints
@onready var hand = $Hand
@onready var deck = $Deck
@onready var fly_home = $FlyHome
@onready var board = $Board

@onready var label = $Label
@onready var state_machine = $StateMachine

signal nextState

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

	label.text = str(playerTurn)
	deck.lockSelf()
	hand.lockSelf()
	fly_home.lockSelf()
	board.lockSelf()
		
	for p in Global.PLAYERS:
		idToLabel[p] = pointsDisplay.instantiate()
		all_points.add_child(idToLabel[p])
		idToLabel[p].setOwnerText(str(p))
	
	# Called here to ensure that all_points is set up to store the points
	if multiplayer.is_server():
		deck.setUpTable()
		
	startTurn.rpc_id(playerTurn)

func _process(_delta):
	pass

@rpc("any_peer", "call_local", "reliable")
func nextTurn():
	assert(multiplayer.is_server(), "Non-Host attempted to start next turn")
	playerTurnIndex += 1
	if playerTurnIndex >= Global.PLAYERS.size():
		playerTurnIndex = 0
	playerTurn = Global.PLAYERS[playerTurnIndex]
	startTurn.rpc_id(playerTurn)

@rpc("any_peer", "call_local", "reliable")
func startTurn():
	
	print("Allow %s to place birds on board" % str(multiplayer.get_unique_id()))
	state_machine.curState = state_machine.curState._nextState()
	print("State: %s", str(state_machine.curState))

@rpc("any_peer", "call_local", "reliable")
func updatePoints(uid: int, cid: String, p: int):
	assert(idToLabel.has(uid), "UID not in idToLabel\n"+str(idToLabel))
	idToLabel[uid].addPoints(cid, p)
	
func _on_button_pressed():
	if playerTurn != multiplayer.get_unique_id():
		print("NOT TURN")
		return
	state_machine.curState = state_machine.states["Wait"]
	state_machine.curState.stateActive()
	nextTurn.rpc_id(1)


func _on_board_birds_placed(birdsCollected: bool):
	# Since birds have been placed lock hand
	board.lockSelf()
	hand.lockSelf()

	if (birdsCollected == false):
		deck.unlockSelf()
	else:
		deck.lockSelf()
		hand.unlockSelf()
		fly_home.unlockSelf()
	print("Birds Collected: %s" % str(birdsCollected))


func _on_deck_cards_drawn():
	hand.unlockSelf()
	fly_home.unlockSelf()


func _on_fly_home_flown_home():
	fly_home.lockSelf()
	hand.lockSelf()
	nextTurn.rpc_id(1)
	
