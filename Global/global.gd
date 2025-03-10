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
## Returns an array of cards which match the small and large threshold
## Scans cards in hand and returns true if any cards can be flown home
func canFlyHome() -> Dictionary:
	var canFlyHomeDict: = {"small": [], "large": []}
	var cardCount: Dictionary
	for card in cardsInHand:
		var key: String = card.data.id
		var sGoal: int = card.data.small
		var lGoal: int = card.data.large
		if cardCount.has(key):
			cardCount[key] += 1
			if !canFlyHomeDict["large"].has(key) and cardCount[key] >= lGoal:
				canFlyHomeDict["small"].erase(key)
				canFlyHomeDict["large"].append(key)
			elif !canFlyHomeDict["small"].has(key) and cardCount[key] >= sGoal:
				canFlyHomeDict["small"].append(key)
		else:
			cardCount[key] = 1

	return canFlyHomeDict

# Return all card Objects with a matching id
func getCardTypeInHand(idArray: Array) -> Array[Object]:
	var matchingCards: Array[Object] = []
	for card in cardsInHand:
		if (idArray.has(card.data.id)):
			matchingCards.append(card)
	return matchingCards
