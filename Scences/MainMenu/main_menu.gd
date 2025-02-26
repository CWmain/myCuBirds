extends Node2D

const PORT = 8712
const IP_ADDRESS = "127.0.0.1"
const MAX_CLIENTS = 6


var table = preload("res://Scences/Table/table.tscn")

@onready var lobby = $Lobby
@onready var status = $Status
var loadedPeers: int = 0

func _ready():
	multiplayer.connected_to_server.connect(_on_server_connect)
	multiplayer.peer_connected.connect(_on_peer_connect)

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

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	status.text = "Host"
	Global.PLAYERS.append(1)

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_server_connect():
	print("Connected")
	status.text = "Client"
	Global.PLAYERS.append(multiplayer.get_unique_id())

# With current method does not include own id in list of PLAYERS
func _on_peer_connect(id: int):
	lobby.addUser(id)
	Global.PLAYERS.append(id)

func _on_start_pressed():
	if multiplayer.is_server():
		startGame.rpc()

@rpc("call_remote", "any_peer", "reliable")
func informExit():
	loadedPeers += 1;
	

@rpc("call_remote","authority", "reliable")
func startGame():
	get_tree().change_scene_to_packed(table)
