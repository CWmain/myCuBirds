extends Node2D

@onready var host_hand = $HostHand
@onready var client_hand = $ClientHand

func _ready():
	multiplayer.peer_connected.connect(_on_connected_to_server)
	if multiplayer.is_server():
		host_hand.set_multiplayer_authority(multiplayer.get_unique_id())
		print("Is host")
	else:
		client_hand.set_multiplayer_authority(multiplayer.get_unique_id())
		print("Is client")

func _process(delta):
	pass

func _on_connected_to_server(id: int):
	client_hand.set_multiplayer_authority(id)
	
	
