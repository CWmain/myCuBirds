extends Node2D

var id: int = 0
@export var newHome: Vector2 = Vector2.ZERO
@export var tname: String = "default"
@export var cardScale: float = 0.2
@onready var container = $Container

var baseCard = preload("res://Objects/Cards/base_card.tscn")
var catCard = preload("res://Objects/Cards/Cat/cat.tres")
var flamingoCard = preload("res://Objects/Cards/Flamingo/Flamingo.tres")
var owlCard = preload("res://Objects/Cards/Owl/Owl.tres")
func _ready():
	addCard(flamingoCard)
	addCard(flamingoCard)
	addCard(catCard)
	addCard(owlCard)

func _process(_delta):
	pass
	
## Adds a card into your hand based on a given resource
func addCard(toAdd: Resource):
	var cc = Control.new()
	var newCard = baseCard.instantiate()
	newCard.data = toAdd
	newCard.scale = Vector2(cardScale,cardScale)
	cc.add_child(newCard)
	container.add_child(cc)
