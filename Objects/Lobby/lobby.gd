extends Control

@onready var connected = $Connected
@onready var new_name_text = $NewNameForm/NewNameText

var idToLabel: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func addUser(id: int):	
	var newUser = Label.new()
	idToLabel[id] = newUser
	if Global.PLAYER_NAMES.has(id):
		newUser.text = str(Global.PLAYER_NAMES[id])
	else:
		newUser.text = "NO WORK"
	connected.add_child(newUser)

func updateLabel(id:int, toWrite: String):
	if idToLabel.has(id):
		idToLabel[id].text = toWrite
	else:
		print("No such id")

## Remove the user id from lobby if it exists
func eraseUser(id: int):
	if !idToLabel.has(id):
		assert(false, "%d: No such id in lobby" % id)
		
	idToLabel[id].queue_free()
	idToLabel.erase(id)

func clearUsers():
	for user in connected.get_children():
		user.queue_free()

# Should only call for yourself
@rpc("any_peer","call_local","reliable")
func updatePlayerName(newName: String):
	var player_id: int = multiplayer.get_remote_sender_id()
	Global.PLAYER_NAMES[player_id] = newName
	updateLabel(multiplayer.get_remote_sender_id(), newName)

func _on_submit_name_pressed():
	updatePlayerName.rpc(new_name_text.text)
