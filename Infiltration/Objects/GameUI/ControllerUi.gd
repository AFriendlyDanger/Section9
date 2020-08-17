extends Control


onready var labelNode = $Panel/Label

func _ready():
	pass # Replace with function body.


func LabelText(text):
	labelNode.text = text
