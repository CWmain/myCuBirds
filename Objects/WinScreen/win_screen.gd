extends Control

@onready var winner_name = $VBoxContainer/WinnerName
@onready var rematch_button = $VBoxContainer/Buttons/Rematch

signal rematch
signal main_menu

func _ready():
	if !multiplayer.is_server():
		rematch_button.disabled = true

func assignWinner(winner: String):
	winner_name.text = winner

func _on_rematch_pressed():
	rematch.emit()


func _on_main_menu_pressed():
	main_menu.emit()
