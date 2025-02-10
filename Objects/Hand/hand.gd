extends Control

class_name Hand

var id: int = 0
@export var newHome: Vector2 = Vector2.ZERO
@export var tname: String = "default"
@export var cardScale: float = 0.2:
	set(value):
		cardScale = value
		updateCardScale()
		
@onready var container = $Container
@export var MAX_SEP: int = 128
@export var MIN_SEP: int = 0
var catCard = preload("res://Objects/Cards/Cat/cat_card.tscn")
var flamingoCard = preload("res://Objects/Cards/Flamingo/flamingo_card.tscn")
var owlCard = preload("res://Objects/Cards/Owl/owl_card.tscn")

func _ready():
	addCard(flamingoCard)
	addCard(catCard)
	addCard(flamingoCard)
	addCard(owlCard)

func _process(_delta):
	pass
	
## Adds a card into your hand based on a given resource
func addCard(toAdd):
	var cc = Control.new()
	var newCard = toAdd.instantiate()
	newCard.scale = Vector2(cardScale,cardScale)
	# Scan for the index of the same card 
	var toAddIndex: int = firstInstance(newCard.data.id)
	cc.add_child(newCard)
	container.add_child(cc)
	container.move_child(cc,toAddIndex)

func firstInstance(matchId: String) -> int:
	var matchIndex: int = 0
	# Loop thru all children of container
	for item in container.get_children():
		if item.get_child(0).data.id == matchId:
			break
		matchIndex += 1
	return matchIndex

## Set cardScale off all created cards
func updateCardScale():
	for c in container.get_children():
		c.get_child(0).scale = Vector2(cardScale,cardScale)
