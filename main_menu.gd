extends PanelContainer


signal game_begin


@onready var start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var credits_button: Button = $MarginContainer/VBoxContainer/CreditsButton
@onready var credits_menu: PanelContainer = $"../Credits"


func _ready() -> void:
	get_tree().paused = true


func do_focus() -> void:
	start_button.grab_focus()


func _on_start_button_pressed() -> void:
	hide()
	get_tree().paused = false
	game_begin.emit()


func _on_credits_back_button_pressed() -> void:
	self.show()
	credits_menu.hide()


func _on_credits_button_pressed() -> void:
	self.hide()
	credits_menu.show()
