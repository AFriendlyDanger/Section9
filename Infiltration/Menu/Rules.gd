extends Control


onready var controls = $PanelContainer/VBoxContainer/Control/ScrollContainer/Options/ControlsCont
onready var rules = $PanelContainer/VBoxContainer/Control/ScrollContainer/Options/RuleCont
onready var classes = $PanelContainer/VBoxContainer/Control/ScrollContainer/Options/ClassCont

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_X_pressed():
	hide()



func _on_Controls_pressed():
	if controls.visible:
		controls.hide()
	else:
		controls.show()


func _on_Rules_pressed():
	if rules.visible:
		rules.hide()
	else:
		rules.show()


func _on_Classes_pressed():
	if classes.visible:
		classes.hide()
	else:
		classes.show()


func _on_RuleButton_pressed():
	show()
