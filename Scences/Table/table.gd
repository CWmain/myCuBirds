extends Control

@onready var all_points = $AllPoints
@onready var hand = $Hand
@onready var deck = $Deck
@onready var fly_home = $FlyHome
@onready var board = $Board

@onready var label = $Label
@onready var curState:
	set(value):
		curState = value
		curState.stateActive()

var main_menu = load("res://Scences/MainMenu/main_menu.tscn")
@onready var wait = $StateMachine/Wait

signal nextState

var idToLabel: Dictionary
var pointsDisplay = preload("res://Objects/PointDisplay/point_display.tscn")

## The mutiplayer id of the person whos turn it is
@export var playerTurn: int = 1:
	set(value):
		playerTurn = value
		label.text = str(value)
var playerTurnIndex: int = 0

var temp: bool = false

func _ready():
	curState = wait
	if multiplayer.is_server():
		print("Is host")
	else:
		print("Is client")
	label.text = str(playerTurn)
		
	for p in Global.PLAYERS:
		idToLabel[p] = pointsDisplay.instantiate()
		all_points.add_child(idToLabel[p])
		idToLabel[p].setOwnerText(str(p))
	
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# Called here to ensure that all_points is set up to store the points
	if multiplayer.is_server():
		deck.setUpTable()		
		startTurn.rpc_id(playerTurn)


## Any player can inform the host to start the next turn
@rpc("any_peer", "call_local", "reliable")
func nextTurn():
	assert(multiplayer.is_server(), "Non-Host attempted to start next turn")
	playerTurnIndex += 1
	if playerTurnIndex >= Global.PLAYERS.size():
		playerTurnIndex = 0
	playerTurn = Global.PLAYERS[playerTurnIndex]
	startTurn.rpc_id(playerTurn)

## Sets the currrent turns players state to placeCard
@rpc("authority", "call_local", "reliable")
func startTurn():
	print("Allow %s to place birds on board" % str(multiplayer.get_unique_id()))
	curState = curState._nextState()
	print("State: %s" % str(curState))

@rpc("any_peer", "call_local", "reliable")
func updatePoints(uid: int, cid: String, p: int):
	assert(idToLabel.has(uid), "UID not in idToLabel\n"+str(idToLabel))
	idToLabel[uid].addPoints(cid, p)

func _on_board_birds_placed(birdsCollected: bool):
	curState = curState._birdState(birdsCollected)
	print("Birds Collected: %s" % str(birdsCollected))

func _on_deck_cards_drawn():
	curState = curState._nextState()

# Loops back to wait, since wait does not trigger endturn manually call it
func _on_fly_home_flown_home():
	curState = curState._nextState()
	# If we have cycled to wait, than trigger next turn
	if curState == wait:
		nextTurn.rpc_id(1)

func _on_pass_pressed():
	curState = curState._nextState()
	# If we have cycled to wait, than trigger next turn
	if curState == wait:
		nextTurn.rpc_id(1)

func _on_draw_pressed():
	deck._on_draw_pressed()

func _on_end_round_pressed():
	deck.triggerNewRound.rpc_id(1)
	curState = curState._nextState()

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	Global.PLAYERS.clear()
	get_tree().change_scene_to_packed(main_menu)
