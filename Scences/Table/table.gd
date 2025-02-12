extends Control

@onready var my_points = $MyPoints

var idToLabel: Dictionary
@onready var all_points = $AllPoints

@onready var hand = $Hand

var points: int = 0

func _ready():
	if multiplayer.is_server():
		print("Is host")
	else:
		print("Is client")
	
	idToLabel[multiplayer.get_unique_id()] = Label.new()
	idToLabel[multiplayer.get_unique_id()].text = str(multiplayer.get_unique_id())
	all_points.add_child(idToLabel[multiplayer.get_unique_id()])
	
	for p in Global.PLAYERS:
		idToLabel[p] = Label.new()
		idToLabel[p].text = str(p)
		all_points.add_child(idToLabel[p])

func _process(_delta):
	# TODO: Consider moving this logic into hand
	# The added Vector is due to cards being centered, so this gives some extra magin
	if (hand.container.size+Vector2(256,256) > self.size and hand.container.get_theme_constant("separation") > hand.MIN_SEP):
		hand.container.add_theme_constant_override("separation", hand.container.get_theme_constant("separation")-1)
	if (hand.container.size+Vector2(256,256) < self.size && hand.container.get_theme_constant("separation") < hand.MAX_SEP):
		hand.container.add_theme_constant_override("separation", hand.container.get_theme_constant("separation")+1)

func _on_button_pressed():
	points += 1
	my_points.text = str(points)
	updatePoints.rpc(multiplayer.get_unique_id(), points)

@rpc("any_peer", "call_local")
func updatePoints(id: int, p: int):
	idToLabel[id].text = "%d: %d" % [id, p]
	
