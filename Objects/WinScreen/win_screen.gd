extends Control

@onready var winner_name = $VBoxContainer/WinnerName

func assignWinner(winner: String):
	winner_name.text = winner
