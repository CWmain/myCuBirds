extends Node
var isHolding: Object = null

var PLAYERS: Array[int]
var cardsInHand: Array[Object]

func clearGlobals():
	PLAYERS.clear()
	cardsInHand.clear()
	isHolding = null
