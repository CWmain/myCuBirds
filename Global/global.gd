extends Node
var isHolding: Object = null

var PLAYERS: Array[int]

## Not in same order as visually displayed
var cardsInHand: Array[Object]

func clearGlobals():
	PLAYERS.clear()
	cardsInHand.clear()
	isHolding = null

# Consider refactoring to another location
## Scans cards in hand and returns true if any cards can be flown home
func canFlyHome() -> bool:
	var cardCount: Dictionary
	for card in cardsInHand:
		var key: String = card.data.id
		var goal: int = card.data.small
		if cardCount.has(key):
			cardCount[key] += 1
			if cardCount[key] >= goal:
				return true
		else:
			cardCount[key] = 0

	return false
