extends Node2D

const PORT = 8712
const IP_ADDRESS = "127.0.0.1"
const MAX_CLIENTS = 6

var table = preload("res://Scences/Table/table.tscn")

func _ready():
	multiplayer.connected_to_server.connect(_on_server_connect)

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_packed(table)


func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_server_connect():
	print("Connected")
	get_tree().change_scene_to_packed(table)
