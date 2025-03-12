extends Control

@onready var all_points = $AllPoints
@onready var hand = $Hand
@onready var deck = $Deck
@onready var fly_home = $FlyHome
@onready var board = $Board

@onready var label = $Label
@onready var curState:
	set(value):
		#print("Previous State: %s" % curState)
		curState = value
		#print("Current State: %s" % curState)
		curState.stateActive()

var main_menu = load("res://Scences/MainMenu/main_menu.tscn")
@onready var wait = $StateMachine/Wait
@onready var flyhome = $StateMachine/Flyhome
@onready var win_screen = $WinScreen

var idToLabel: Dictionary
var pointsDisplay = preload("res://Objects/PointDisplay/point_display.tscn")

## The mutiplayer id of the person whos turn it is
@export var playerTurn: int = 1:
	set(value):
		playerTurn = value
		label.text = str(value)
var playerTurnIndex: int = 0

var loadedPeers: int = 0

var mainMenuBool: bool = false
var reloadTable: bool = false

func _ready():
	curState = wait
	if multiplayer.is_server():
		print("Is host")
	else:
		print("Is client")
	label.text = str(playerTurn)
		
	for p in Global.PLAYERS:
		idToLabel[p] = pointsDisplay.instantiate()
		idToLabel[p].myDeck = deck
		all_points.add_child(idToLabel[p])
		idToLabel[p].setOwnerText(Global.PLAYER_NAMES[p])
	
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.peer_connected.connect(_refuse_new_connection)

	# Called here to ensure that all_points is set up to store the points
	if multiplayer.is_server():
		deck.setUpTable()		
		startTurn.rpc_id(playerTurn)

func _process(_delta):
	if Input.is_action_just_pressed("GiveCard"):
		hand.addCardFromResource(str_to_var(deck.topCard()))
	if Input.is_action_just_pressed("DebugWin"):
		endGame.rpc(Global.PLAYER_NAMES[multiplayer.get_unique_id()])
	if Input.is_action_just_pressed("RemoveCardsInDeck"):
		deck.cards.clear()
		deck.updateCardCount()
		

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

func checkGameOver():
	# Check the point total for each player
	for p in Global.PLAYERS:
		var sevenSpecies: int = 0
		var twoWithThree: int = 0
		var playerPoints: Dictionary = idToLabel[p].scoreTracker

		for key in playerPoints:
			if playerPoints[key] >= 3:
				sevenSpecies += 1
				twoWithThree += 1
			elif playerPoints[key] > 0:
				sevenSpecies += 1
			print("%s: %d" % [key, playerPoints[key]])
			
		if sevenSpecies >= 7 or twoWithThree >= 2:
			endGame.rpc(Global.PLAYER_NAMES[p])
	
@rpc("any_peer","call_local","reliable")
func endGame(winner: String):
	print("Attempting to endGame")
	win_screen.assignWinner(winner)
	win_screen.show()


# Loops back to wait, since wait does not trigger endturn manually call it
func _on_fly_home_flown_home():
	curState = curState._nextState()
	checkGameOver()
	# If we have cycled to wait, than trigger next turn
	if curState == wait:
		nextTurn.rpc_id(1)

# Both no birds to fly home and pass link to this
# Store a local copy of curState to prevent weird race conditionsa for the next
# turn check
func _on_pass_pressed():
	var localCurState = curState._nextState()
	curState = localCurState
	print("On Pass: %s" % localCurState)

	# If we have cycled to wait, than trigger next turn
	# Ensure the prevState was flyHome to avoid race conditions
	if localCurState == wait:
		nextTurn.rpc_id(1)

func _on_draw_pressed():
	deck._on_draw_pressed()

## When the server goes down, disconnect from server
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	Global.clearGlobals()
	get_tree().change_scene_to_packed(main_menu)

## Remove all references to Player
func _on_peer_disconnected(id: int):
	# Preventing the disconnect signal causes weird errors, therefore allow
	# disconnect signal and filter out new connects here 
	if (!Global.PLAYERS.has(id)):
		return
	print("Disconnect Peer Triggered")
	# If you are host and it is peers turn, go to next turn
	if multiplayer.is_server() and playerTurn == id:
		nextTurn.rpc_id(1)
	# Remove peers points from AllPoints
	idToLabel[id].queue_free()
	idToLabel.erase(id)
	Global.PLAYERS.erase(id)

func _refuse_new_connection(id: int):
	if multiplayer.is_server():
		# Preventing the disconnect signal causes weird errors, therefore allow
		# disconnect signal and filter out in _on_peer_disconnect()
		multiplayer.multiplayer_peer.disconnect_peer(id, false)
	

func _exit_tree():
	print("\nExited tree\n")
	Global.cardsInHand.clear()
	Global.isHolding = null
	if !multiplayer.is_server():
		informExit.rpc_id(1)

@rpc("call_remote", "any_peer", "reliable")
func informExit():
	loadedPeers += 1;
	if mainMenuBool and loadedPeers == Global.PLAYERS.size()-1:
		get_tree().change_scene_to_packed(main_menu)
	if reloadTable and loadedPeers == Global.PLAYERS.size()-1:
		get_tree().reload_current_scene()

@rpc("call_remote","authority", "reliable")
func GoToMainMenu():
	get_tree().change_scene_to_packed(main_menu)
	
@rpc("call_remote","authority", "reliable")
func GoToTable():
	get_tree().reload_current_scene()
	
func _on_win_screen_main_menu():
	if !multiplayer.is_server():
		multiplayer.multiplayer_peer.disconnect_peer(1)
	mainMenuBool = true
	GoToMainMenu.rpc()


func _on_win_screen_rematch():
	reloadTable = true
	GoToTable.rpc()

func _on_end_round_end_round():
	deck.triggerNewRound.rpc_id(1)
	curState = curState._nextState()


func _on_deck_out_of_cards():
	print("OUT OF CARDS!!!")
	endGame.rpc("Out of cards!!!")


func _on_flyhome_no_cards_to_fly_home():
	curState = curState._nextState()
	print("On No Fly Home: %s" % curState)

	# If we have cycled to wait, than trigger next turn
	if curState == wait:
		print("AA: FlyHome next turn is used")
		nextTurn.rpc_id(1)
