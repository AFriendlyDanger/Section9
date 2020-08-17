extends Control


var player
onready var optionsNode = $"../VolumeControl/"
onready var rulesNode = $"../Rules/"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func show_menu(activator):
	player = activator
	show()


func _on_Resume_pressed():
	player.set_process(true)
	hide()


func _on_End_Turn_pressed():
	player.rpc("EndTurn")
	hide()


func _on_Settings_pressed():
	optionsNode.show()
	pass # Replace with function body.


func _on_Exit_pressed():
	get_tree().quit()


func _on_Rules_pressed():
	rulesNode.show()
