extends Node2D
#tool

var tiles = []
var pieces = []
var players = []
var security = []
var mainframes = []
var turns = 0
var player_turn = 0
onready var camera = $Camera
onready var piece_steps = $CanvasLayer/PieceSteps/Label
onready var step_pool = $CanvasLayer/StepPool/Label

#signal game_finished()

func _ready():
	tiles.resize(self.get_node("Tiles").get_child_count())
	print(tiles.size())
	var tileNode = get_node("Tiles")
	for child in tileNode.get_children():
		var arrayNum = child.position.x/16 + child.position.y/16*Global.BOARDWIDTH
		tiles[arrayNum] = child
	#set Map.gd and Tile.gd as tool to automatically arrange tile sprites 
	if Engine.editor_hint:
		for t in range(tiles.size()):
			var tiledata = 0
			if !tiles[t].wall:
				SetGroundtile(t,tiledata)
			elif tiles[t].door:
				SetDoortile(t)
			elif !tiles[t].console:
				SetWalltile(t,tiledata)
	
	#camera.limit_left = 0
	#camera.limit_right = 16 * Global.BOARDWIDTH
	pieces = get_tree().get_nodes_in_group("Piece")
	security = get_tree().get_nodes_in_group("Security")
	players = get_tree().get_nodes_in_group("Player")
	mainframes = get_tree().get_nodes_in_group("Mainframe")
	
	if get_tree().is_network_server():
		# For the server, give control of player 2 to the other peer. 
		players[1].set_network_master(get_tree().get_network_connected_peers()[0],true)
	else:
		# For the client, give control of player 2 to itself.
		players[1].set_network_master(get_tree().get_network_unique_id(),true)
	print("unique id: ", get_tree().get_network_unique_id())
	players[player_turn].rpc("StartTurn")
	#SetWalltile(95+BOARDWIDTH,0)
			
			
func _process(delta):
	if Input.is_action_just_pressed("scroll_right"):
		camera.translate(Vector2.RIGHT*delta*100)
	elif Input.is_action_pressed("scroll_right"):
		camera.translate(Vector2.RIGHT*delta*50)
	elif Input.is_action_just_pressed("scroll_left") && camera.position.x > 0:
		camera.translate(Vector2.LEFT*delta*100)
	elif Input.is_action_pressed("scroll_left") && camera.position.x > 0:
		camera.translate(Vector2.LEFT*delta*50)
	FixCamera()

#setting camera bounds this way because I was getting input delay when the bounds
#on the camera node were pushed against
func FixCamera():
	var maxDistance = 16 * Global.BOARDWIDTH/2
	if camera.position.x < 0:
		camera.position = Vector2.ZERO
	elif camera.position.x > maxDistance:
		camera.position = Vector2(maxDistance,0)

func SetGroundtile(tileLoc,tiledata):
	var bordertile = tileLoc-Global.BOARDWIDTH-1
	#find tile topleft of target
	if !(bordertile<0||(bordertile+1)%Global.BOARDWIDTH==0):
		tiledata = (tiledata << 2) | tiles[bordertile].status()
	#find tile top of target
	bordertile += 1
	if !(bordertile<0):
		tiledata = (tiledata << 2) | tiles[bordertile].status()
	#find tile left of target
	bordertile = tileLoc-1
	if !((bordertile+1)%Global.BOARDWIDTH==0):
		tiledata = (tiledata << 2) | tiles[bordertile].status()
	tiles[tileLoc].setTile(tiledata)
	
func SetDoortile(tileLoc):
	var bordertile = tileLoc-Global.BOARDWIDTH
	if(!(bordertile<0) && tiles[bordertile].wall):
		tiles[tileLoc].frame = 20

func SetWalltile(tileLoc,tiledata):
	var bordertile = tileLoc-Global.BOARDWIDTH-1
	for _y in range(3):
		for _x in range(3):
			if(bordertile>=0 && (bordertile+1)%Global.BOARDWIDTH != 0 && bordertile<tiles.size()):
				if(bordertile!=tileLoc):
					tiledata = (tiledata << 2) | tiles[bordertile].status(true)
			else:
				if(bordertile!=tileLoc):
					tiledata = (tiledata << 2) | 3
			bordertile += 1
		bordertile += (Global.BOARDWIDTH - 3)
	tiles[tileLoc].setTile(tiledata)
	
func ValidMove(tileLoc,finalMove,moving_piece):
	var occupied_space = false
	for piece in pieces:
		if piece.alive && piece.boardpos == tileLoc:
			occupied_space = true
	var validMove = tiles[tileLoc].MovementTile()
	if(finalMove && validMove):
		for piece in pieces:
			if piece.boardpos == tileLoc && piece.alive:
				validMove = false
				break
	if occupied_space && validMove:
		moving_piece.must_move = true
	elif moving_piece.must_move && validMove:
		moving_piece.must_move = false
	return validMove

func attackHit(tileLocs,attacker):
	var stopSearch = false
	var kill = false
	for loc in tileLocs:
		if(abs(attacker.facing)==Global.RIGHT):
			if int(attacker.boardpos/Global.BOARDWIDTH)!=int(loc/Global.BOARDWIDTH):
				if attacker.classType != Global.Class.Hacker:
					tileLocs.erase(loc)
		else:
			if loc < 0 || loc >= tiles.size():
				tileLocs.erase[loc]
	if tileLocs.empty():
		return kill
	for piece in pieces:
		if !piece.alive || attacker.playerNode == piece.playerNode:
			continue
		for loc in tileLocs:
			if loc == piece.boardpos:
				if attacker.classType == Global.Class.Ghost:
					if piece.classType == Global.Class.Security && piece.defending\
					&& piece.facing != attacker.facing:
						stopSearch = true
						break
					elif piece.facing * -1 != attacker.facing:
						print("assassinated")
						piece.rpc("Killed")
						stopSearch = true
						kill = true
						break
				elif attacker.classType == Global.Class.Security && HitBlocked(loc,piece.facing):
					stopSearch = true
					break
				else:
					if piece != attacker:
						piece.rpc("Killed")
						kill = true
			if stopSearch:
				break
	return kill


func TurnChange():
	player_turn += 1
	if player_turn > players.size()-1:
		player_turn = 0
		turns += 1
		for mainframe in mainframes:
			if mainframe.uploading && mainframe.UploadOver():
				GameEnd(1)
				return
	RecalcLOS()
	players[player_turn].StartTurn()


func HitBlocked(tile, facing):
	for sec in security:
		if sec.boardpos == tile && sec.defending && sec.alive && sec.facing != facing:
			return true
	return false


func CheckHit(tileLoc,parentName,target):
	var killed = false
	for piece in security:
		if piece.alive && piece.action_taken\
		&& piece.get_parent().name != parentName:
			if target.classType == Global.Class.Security && target.defending \
			&& piece.facing != target.facing:
				continue
			else:
				for tile in piece.sight:
					if HitBlocked(tile,piece.facing):
						break
					if tile == tileLoc:
						killed = true
						return killed
	return killed


func RecalcLOS():
	for sec in security:
		if sec.alive && !sec.defending:
			sec.sight = LineOfSight(sec.boardpos, sec.facing)
	for piece in pieces:
		if CheckHit(piece.boardpos, piece.get_parent().name, piece):
			piece.Killed()


func LineOfSight(tileLoc,direction):
	var sight = []
	while tiles[tileLoc].status() != 3 || tiles[tileLoc].open:
		sight.append(tileLoc)
		tileLoc += direction
		if tileLoc < 0 || tileLoc >= tiles.size():
			break
	return sight


func NextSelect(current,direction):
	var selection = current
	for piece in pieces:
		if !piece.alive || piece.action_taken:
			continue
		if piece.get_parent().name == current.get_parent().name:
			if direction==Global.UP:
				if piece.position.y < current.position.y && (selection==current || piece.position.y >= selection.position.y):
					if piece.position.y == selection.position.y:
						var pieceDist = abs(current.position.x - piece.position.x)
						var selectDist = abs(current.position.x - selection.position.x)
						if pieceDist < selectDist:
							selection = piece
						elif pieceDist == selectDist && piece.position.x > selection.position.x:
							selection = piece
					else:
						selection = piece
			elif direction==Global.DOWN:
				if piece.position.y > current.position.y && (selection==current || piece.position.y <= selection.position.y):
					if piece.position.y == selection.position.y:
						var pieceDist = abs(current.position.x - piece.position.x)
						var selectDist = abs(current.position.x - selection.position.x)
						if pieceDist < selectDist:
							selection = piece
						elif pieceDist == selectDist && piece.position.x < selection.position.x:
							selection = piece
					else:
						selection = piece
			elif direction==Global.LEFT:
				if piece.position.y == current.position.y && piece.position.x < current.position.x && \
				(selection==current || piece.position.x > selection.position.x):
					selection = piece
			elif direction==Global.RIGHT:
				if piece.position.y == current.position.y && piece.position.x > current.position.x && \
				(selection==current || piece.position.x < selection.position.x):
					selection = piece
			else:
				print("Invalid direction sent: ", direction)
	camera.position = Vector2(selection.position.x-Global.BOARDWIDTH*4,0)
	FixCamera()
	SetPieceSteps(selection.MAX_MOVES - selection.total_moves)
	return selection


func SetPieceSteps(steps):
	piece_steps.text = "STEPS:%s" % String(steps)


func SetStepPool(pool,steps):
	SetPieceSteps(steps)
	step_pool.text = "POOL:%s" % String(pool)


func GameEnd(team = 0):
	if team == 1:
		print("Infultrators Win")
	else:
		print("Defense Wins")
