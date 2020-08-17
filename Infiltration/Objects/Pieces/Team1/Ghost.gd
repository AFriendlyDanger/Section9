extends "res://Objects/Pieces/Piece.gd"

func _ready():
	classType = Global.Class.Ghost
	
func Attack():
	if mapNode.attackHit([boardpos+facing],self):
		ActionUsed()

func Interact():
	if rpc("UploadVirus",int(boardpos+facing)):
		ActionUsed()



func _on_Area2D_area_entered(_area):
	if !is_network_master() && alive:
		visible = true
	cloaked = false
	



func _on_Area2D_area_exited(_area):
	if !is_network_master():
		visible = false
	cloaked = true


func set_ui():
	mapNode.attack_ui.LabelText("Attack")
	mapNode.attack_ui.visible = true
	.set_ui()
	mapNode.select_ui.visible = false

