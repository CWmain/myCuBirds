extends Node2D

var id: int = 0
@export var newHome: Vector2 = Vector2.ZERO
@export var tname: String = "default"

func _ready():
	pass

func _process(_delta):
	pass


func _on_container_child_exiting_tree(node):
	for card in get_tree().get_nodes_in_group("card"):
		card.home = to_global(card.get_parent().position)
		print(card.home)
