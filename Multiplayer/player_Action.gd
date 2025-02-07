extends MultiplayerSynchronizer

@export var mouse_coordinates: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	# Only runs if we are the multiplayer authority
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Grab"):
		click.rpc()

@rpc("call_local")
func click():
	mouse_coordinates = get_tree().get_global_mouse_position()
