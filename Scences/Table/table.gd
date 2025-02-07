extends Node2D

@onready var host_hand = $HostHand
@onready var client_hand = $ClientHand

@onready var my_points = $MyPoints
@onready var their_points = $TheirPoints

var points: int = 0

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
	
	
func _on_button_pressed():
	points += 1
	my_points.text = str(points)
	updateTheirPoints.rpc(points)

@rpc("any_peer", "call_remote")
func updateTheirPoints(p: int):
	their_points.text = str(p)
	
