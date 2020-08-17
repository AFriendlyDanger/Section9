extends Panel


onready var WinnerNode = $VBoxContainer/Winner

func _ready():
	pass # Replace with function body.

func WinText(winner):
	WinnerNode.text = winner

func _on_EXIT_pressed():
	get_tree().quit()
