extends Node2D

const PORT = 8712
const IP_ADDRESS = "127.0.0.1"
const MAX_CLIENTS = 6


var table = preload("res://Scences/Table/table.tscn")

@onready var status = $Status

func _ready():
	multiplayer.connected_to_server.connect(_on_server_connect)
	multiplayer.peer_connected.connect(_on_peer_connect)

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	status.text = "Host"

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_server_connect():
	print("Connected")
	status.text = "Client"

# With current method does not include own id in list of PLAYERS
func _on_peer_connect(id: int):
	Global.PLAYERS.append(id)
	print(Global.PLAYERS)

func _on_start_pressed():
	if multiplayer.is_server():
		startGame.rpc()

@rpc("call_local","authority")
func startGame():
	get_tree().change_scene_to_packed(table)
