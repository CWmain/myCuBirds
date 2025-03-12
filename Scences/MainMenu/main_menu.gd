extends Control

const PORT = 8712
# Lan IP Address
var IP_ADDRESS = "192.168.0.99"
const MAX_CLIENTS = 6


var table = preload("res://Scences/Table/table.tscn")

@onready var host = $VBoxContainer/Host
@onready var join = $VBoxContainer/Join
@onready var start = $VBoxContainer/Start

@onready var lobby = $Lobby
@onready var status = $Status
@onready var text_edit = $VBoxContainer/TextEdit
var loadedPeers: int = 0
var default_names: Array = ["Emma", "Liam", "Olivia", "Noah", "Ava", "Jackson", "Sophia", "Aiden", "Isabella", "Lucas", "Mia", "Caden", "Amelia", "Grayson", "Harper", "Elijah", "Evelyn", "Logan", "Aria", "James", "Lily", "Benjamin", "Chloe", "Mason", "Ella", "Sebastian", "Zoe", "William", "Charlotte", "Jacob", "Scarlett", "Michael", "Madison", "Alexander", "Emily", "Henry", "Abigail", "Jackson", "Grace", "Owen", "Sophie", "Daniel", "Victoria", "Matthew", "Hannah", "Samuel", "Nora", "David", "Addison", "Joseph", "Leah", "John", "Natalie", "Wyatt", "Eleanor", "Jack", "Lucy", "Isaac", "Aubrey", "Ryan", "Bella", "Luke", "Stella", "Ethan", "Mila", "Julian", "Lila", "Leo", "Riley", "Gabriel", "Eva", "Caleb", "Layla", "Charles", "Paisley", "Carter", "Ivy", "Ezra", "Victoria", "Matthew", "Grace", "Miles", "Zara", "Jordan", "Elena", "Asher", "Samantha", "Luke", "Sadie", "Cora", "Blake", "Anna", "Wyatt", "Naomi", "Julian", "Clara", "Xander", "Zoe", "Kai", "Piper", "Jaxon", "Madeline", "Hudson", "Avery", "Colton", "Adeline", "Nathan", "Riley", "Leo", "Zara", "Harrison", "Leah", "Christian", "Lyla", "Brayden", "Sienna", "Elliott", "Violet", "Nolan", "Catherine", "Eli", "Eva", "Miles", "Holly", "Wyatt", "Maya", "Everett", "Georgia", "Benjamin", "Harper", "Jackson", "Amaya", "Gracie", "Austin", "Addison", "Landon", "Sarah", "Maddox", "Freya", "Austin", "Vivian", "Lucas", "Olivia", "Aiden", "Charlotte", "Brody", "Lena", "Owen", "Taylor", "Sophia", "Parker", "Maya", "Gabriel", "Sadie", "Jude", "Ariana", "Declan", "Zoey", "Roman", "Emery", "Elliot", "Everly", "Evan", "Ariana", "Charlotte", "Penelope", "Jack", "Madeline", "Eden", "Leo", "Amos", "Lila", "Sophie", "Aidan", "Harper", "James", "Nora", "Hunter", "Zoe", "Emery", "Ella", "Everett", "Brooklyn", "Abigail", "Jordan", "Elise", "Avery", "Mason", "Zara", "Ella", "Bennett", "Tessa", "Nina", "Carson", "Jade", "Aiden", "Daisy", "Luca", "Autumn", "Mason", "Eliza", "Isla", "Chloe", "Oscar", "Jasmine"]

func _ready():
	multiplayer.connected_to_server.connect(_on_server_connect)
	multiplayer.peer_connected.connect(_on_peer_connect)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnect)
	multiplayer.connection_failed.connect(_on_server_disconnect)

	if Global.PLAYERS.size() > 0:
		toggleButtons()

func _process(_delta):
	# Ensure loadedPeers are above 0, as when no one has connected 
	# loadedPeers is equal to Players.size()-1 as the host is part of
	# the list (0 == 0)

	if loadedPeers > 0 and loadedPeers == Global.PLAYERS.size()-1:
		get_tree().change_scene_to_packed(table)

# Assumed when tree is exited client has loaded into the game scene,
# should think about how client's will disconect
func _exit_tree():
	# Inform the host that you have swapped scenes
	if !multiplayer.is_server():
		informExit.rpc_id(1)

func toggleButtons():
	host.disabled = true
	join.disabled = true
	if !multiplayer.is_server():
		start.disabled = true

func resetButtons():
	host.disabled = false
	join.disabled = false
	start.disabled = false

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	status.text = "Host"
	Global.PLAYERS.append(1)
	
	var randomName: String = generateRandomName()
	Global.PLAYER_NAMES[multiplayer.get_unique_id()] = randomName
	
	toggleButtons()

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_server_connect():
	print("Connected")
	status.text = "Client"
	Global.PLAYERS.append(multiplayer.get_unique_id())
	
	# Once connect to the server, generate your unique name
	var randomName: String = generateRandomName()
	Global.PLAYER_NAMES[multiplayer.get_unique_id()] = randomName
	
	toggleButtons()

# With current method does not include own id in list of PLAYERS
func _on_peer_connect(id: int):
	# Requesting player name both updates Global.PLAYER_NAMES and updates the label
	requestPlayerName.rpc_id(id)

	lobby.addUser(id)
	Global.PLAYERS.append(id)

func _on_peer_disconnected(id: int):
	Global.PLAYERS.erase(id)
	lobby.eraseUser(id)

func _on_server_disconnect():
	Global.PLAYERS.clear()
	lobby.clearUsers()
	resetButtons()

func _on_start_pressed():
	if multiplayer.is_server():
		startGame.rpc()

@rpc("call_remote", "any_peer", "reliable")
func informExit():
	loadedPeers += 1;
	

@rpc("call_remote","authority", "reliable")
func startGame():
	get_tree().change_scene_to_packed(table)


func _on_text_edit_text_changed():
	IP_ADDRESS = text_edit.text

@rpc("any_peer","call_remote","reliable")
func requestPlayerName():
	var myName: String = Global.PLAYER_NAMES[multiplayer.get_unique_id()]
	responseWithPlayerName.rpc_id(multiplayer.get_remote_sender_id(), myName)

@rpc("any_peer","call_remote","reliable")
func responseWithPlayerName(answer: String):
	Global.PLAYER_NAMES[multiplayer.get_remote_sender_id()] = answer
	lobby.updateLabel(multiplayer.get_remote_sender_id(), answer)

func generateRandomName() -> String:
	return default_names[(default_names.size()-1)*randf()]
