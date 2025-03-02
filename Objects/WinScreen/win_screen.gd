extends Control

@onready var winner_name = $VBoxContainer/WinnerName

signal rematch
signal main_menu

func assignWinner(winner: String):
	winner_name.text = winner


func _on_rematch_pressed():
	rematch.emit()


func _on_main_menu_pressed():
	main_menu.emit()
