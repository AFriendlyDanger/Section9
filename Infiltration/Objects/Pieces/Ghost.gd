extends "res://Objects/Pieces/Piece.gd"

func _ready():
	pass
	
func Attack():
	mapNode.attackHit([boardpos+facing],self)

func Interact():
	print("interact")
	destroyWall(int(boardpos+facing))

func destroyWall(wallpos):
	if wallpos>Global.BOARDWIDTH && wallpos<mapNode.tiles.size()-Global.BOARDWIDTH \
	&& !(wallpos%Global.BOARDWIDTH == 0 || wallpos%Global.BOARDWIDTH == Global.BOARDWIDTH-1):
		var tile = mapNode.tiles[wallpos]
		if tile.wall:
			tile.intact = false
			tile.frame = 8


func _on_Area2D_area_entered(_area):
	print("Hitbox entered")
	visible = true
	



func _on_Area2D_area_exited(_area):
	print("Hitbox exited")
	visible = false
