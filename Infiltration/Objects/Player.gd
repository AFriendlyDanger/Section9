extends Node2D
const MAX_MOVES = 30
var moves_taken = 0
export var player = 0

const pathTiles = preload("res://Objects/path.tscn")
var selector
var turn = true
onready var mapNode = $"../"
onready var selection = get_child(1)
var pieces = []

func _ready():
	pieces = get_children()
	selector = pathTiles.instance() 
	selector.frame = 5
	selector.z_index = 30
	selector.centered = false
	SetSelection()
	add_child(selector)
	
func _process(_delta):
	if(turn):
		PieceSelect()

func PieceSelect():
	if Input.is_action_just_pressed("ui_accept"):
		selection._activate()
	elif Input.is_action_just_pressed("ui_start"):
		EndTurn()
	elif Input.is_action_just_pressed("ui_right"):
		selection = mapNode.NextSelect(selection,Global.RIGHT)
		SetSelection()
	elif Input.is_action_just_pressed("ui_left"):
		selection = mapNode.NextSelect(selection,Global.LEFT)
		SetSelection()
	elif Input.is_action_just_pressed("ui_up"):
		selection = mapNode.NextSelect(selection,Global.UP)
		SetSelection()
	elif Input.is_action_just_pressed("ui_down"):
		selection = mapNode.NextSelect(selection,Global.DOWN)
		SetSelection()

func SetSelection():
	selector.position = selection.position

func EndTurn():
	turn = false
	selector.visible = false
	set_process(false)
