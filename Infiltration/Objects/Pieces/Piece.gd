extends Node2D

const pathTiles = preload("res://Objects/path.tscn")
const MAX_MOVES = 10
var total_moves = 0
remotesync var action_taken = false
var team = 0
var alive = true
var active = false
var cloaked = false
remotesync var facing = Global.DOWN
var boardpos = 0
var charSprite
var directionTile
var moving = false
var must_move = false
var classType = Global.Class.Demoman
onready var mapNode = $"../../"
onready var playerNode = $"../"


func _ready():
	charSprite = get_child(0)
	boardpos=position.x/16 + position.y/16*Global.BOARDWIDTH
	directionTile = pathTiles.instance()
	directionTile.frame = 2
	point()
	add_child(directionTile)
	set_process(false)
	SpriteLayer()

func _activate(status = true):
	if is_network_master():
		playerNode.selector.visible = !status
	active = status
	playerNode.set_process(!status)
	set_process(status)
	if !status:
		if action_taken:
			playerNode.FindNewSelection()
		playerNode.SetSelection()
	
func _process(_delta):
	if is_network_master():
		if(!moving):
			inputCheck()

func inputCheck():
	if Input.is_action_just_pressed("attack"):
		if !must_move:
			Attack()
	elif Input.is_action_just_pressed("interact"):
		if !must_move:
			Interact()
	elif Input.is_action_just_pressed("ui_cancel"):
		if !must_move:
			_activate(false)
	elif Input.is_action_just_pressed("ui_right"):
		if not facing == Global.RIGHT:
			facing = Global.RIGHT
			rset("facing",facing)
		else:
			move(boardpos+Global.RIGHT,Vector2.RIGHT*16)
		rpc("point")
	elif Input.is_action_just_pressed("ui_left"):
		if not facing == Global.LEFT:
			facing = Global.LEFT
			rset("facing",facing)
		else:
			move(boardpos+Global.LEFT,Vector2.LEFT*16)
		rpc("point")
	elif Input.is_action_just_pressed("ui_up"):
		if not facing == Global.UP:
			facing = Global.UP
			rset("facing",facing)
		else:
			move(boardpos+Global.UP,Vector2.UP*16)
		rpc("point")
	elif Input.is_action_just_pressed("ui_down"):
		if not facing == Global.DOWN:
			facing = Global.DOWN
			rset("facing",facing)
		else:
			move(boardpos+Global.DOWN,Vector2.DOWN*16)
		rpc("point")

func move(destination,movement):
	var pmoves = playerNode.moves_taken
	var pmax = playerNode.MAX_MOVES
	if mapNode.ValidMove(destination,MAX_MOVES-total_moves==1||playerNode.MAX_MOVES-playerNode.moves_taken == 1,self) \
	&& total_moves < MAX_MOVES && pmoves < pmax:
		rpc("update_position",destination,movement,pmoves,pmax)

remotesync func update_position(destination,movement,pmoves,pmax):
		position += movement
		boardpos = destination
		SpriteLayer()
		total_moves += 1
		pmoves += 1
		playerNode.moves_taken = pmoves
		mapNode.SetStepPool(pmax-pmoves,MAX_MOVES-total_moves)
		if visible:
			mapNode.camera.position = Vector2(global_position.x-Global.BOARDWIDTH*4,0)
			mapNode.FixCamera()
		if(!cloaked && mapNode.CheckHit(boardpos,get_parent().name,self)):
			Killed()

remotesync func point():
	if facing==Global.UP:
		directionTile.position = Vector2(8,-8)
		directionTile.rotation_degrees = 0
	elif facing==Global.DOWN:
		directionTile.position = Vector2(8,24)
		directionTile.rotation_degrees = 180
	elif facing==Global.LEFT:
		directionTile.position = Vector2(-8,8)
		directionTile.rotation_degrees = -90
	elif facing==Global.RIGHT:
		directionTile.position = Vector2(24,8)
		directionTile.rotation_degrees = 90

func SpriteLayer():
	charSprite.z_index = int(boardpos/Global.BOARDWIDTH)+3

remotesync func UploadVirus(conspos):
	if conspos>Global.BOARDWIDTH && conspos<mapNode.tiles.size()-Global.BOARDWIDTH:
		if mapNode.tiles[conspos].mainframe:
			return mapNode.tiles[conspos].StartUpload(classType,playerNode.player)

func Attack():
	#Virtual function
	pass

remotesync func Killed():
	alive = false
	visible = false
	playerNode.pieces.erase(self)
	print(playerNode.pieces)
	if active:
		_activate(false)
		playerNode.FindNewSelection()
	if playerNode.pieces.empty():
		mapNode.GameEnd(playerNode.player)
		
func NewTurn():
	total_moves = 0
	action_taken = false

func Interact():
	#Virtual function
	pass

func ActionUsed():
	rset("action_taken", true)
	_activate(false)
