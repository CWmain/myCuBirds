extends Control

@onready var v_box_container = $VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func addUser(id: int):
	var newUser = Label.new()
	newUser.text = str(id)
	v_box_container.add_child(newUser)

## Remove the user id from lobby if it exists
func eraseUser(id: int):
	for user in v_box_container.get_children():
		if user.text == str(id):
			user.queue_free()
			return
	assert(true, "%d: No such id in lobby" % id)

func clearUsers():
	for user in v_box_container.get_children():
		user.queue_free()
