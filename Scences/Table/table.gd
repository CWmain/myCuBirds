extends Control

@onready var all_points = $AllPoints
@onready var hand = $Hand

var idToLabel: Dictionary
var pointsDisplay = preload("res://Objects/PointDisplay/point_display.tscn")

func _ready():
	if multiplayer.is_server():
		print("Is host")
	else:
		print("Is client")
	
	idToLabel[multiplayer.get_unique_id()] = pointsDisplay.instantiate()
	all_points.add_child(idToLabel[multiplayer.get_unique_id()])
	idToLabel[multiplayer.get_unique_id()].setOwnerText(str(multiplayer.get_unique_id()))
	for p in Global.PLAYERS:
		idToLabel[p] = pointsDisplay.instantiate()
		all_points.add_child(idToLabel[p])
		idToLabel[p].setOwnerText(str(p))

func _process(_delta):
	# TODO: Consider moving this logic into hand
	# The added Vector is due to cards being centered, so this gives some extra magin
	if (hand.container.size+Vector2(256,256) > self.size and hand.container.get_theme_constant("separation") > hand.MIN_SEP):
		hand.container.add_theme_constant_override("separation", hand.container.get_theme_constant("separation")-1)
	if (hand.container.size+Vector2(256,256) < self.size && hand.container.get_theme_constant("separation") < hand.MAX_SEP):
		hand.container.add_theme_constant_override("separation", hand.container.get_theme_constant("separation")+1)

@rpc("any_peer", "call_local")
func updatePoints(uid: int, cid: String, p: int):
	assert(idToLabel.has(uid), str(idToLabel))
	idToLabel[uid].addPoints(cid, p)
	
