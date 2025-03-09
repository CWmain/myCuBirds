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
func canFlyHome() -> Array[String]:
	var canFlyHomeList: Array[String] = []
	var cardCount: Dictionary
	for card in cardsInHand:
		var key: String = card.data.id
		var goal: int = card.data.small
		if cardCount.has(key):
			cardCount[key] += 1
			if cardCount[key] >= goal and !canFlyHomeList.has(key):
				canFlyHomeList.append(key)
		else:
			cardCount[key] = 1
	print(cardCount)
	return canFlyHomeList

# Return all card Objects with a matching id
func getCardTypeInHand(idArray: Array[String]) -> Array[Object]:
	var matchingCards: Array[Object] = []
	for card in cardsInHand:
		if (idArray.has(card.data.id)):
			matchingCards.append(card)
	return matchingCards
