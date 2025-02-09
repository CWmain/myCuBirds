extends Control

class_name Hand

var id: int = 0
@export var newHome: Vector2 = Vector2.ZERO
@export var tname: String = "default"
@export var cardScale: float = 0.2
@onready var container = $Container

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
	cc.add_child(newCard)
	container.add_child(cc)
