extends Panel

const DEFAULT_PORT = 2501

onready var address = $Address
onready var host_button = $HostButton
onready var join_button = $JoinButton
onready var status = $Status

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(_id):
	var infiltration = load("res://Level1.tscn").instance()
# Connect deferred so we can safely erase it from the callback.
	#infiltration.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)
	
	get_tree().get_root().add_child(infiltration)
	get_parent().get_parent().hide()
	hide()


func _player_disconnected(_id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	print("connected ok")


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	_set_status("Couldn't connect")
	
	get_tree().set_network_peer(null) # Remove peer.
	
	host_button.set_disabled(false)
	join_button.set_disabled(false)


func _server_disconnected():
	_end_game("Server disconnected")

##### Game creation functions ######

func _end_game(with_error = ""):
	if has_node("/root/Level1"):
		# Erase immediately, otherwise network might show errors (this is why we connected deferred above).
		get_node("/root/Level1").free()
		get_parent().get_parent().show()
		show()
	
	get_tree().set_network_peer(null) # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)
	
	_set_status(with_error)


func _set_status(text):
	# Simple way to show status.
	status.set_text(text)


func _on_HostButton_pressed():
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT, 1) # Maximum of 1 peer, since it's a 2-player game.
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.")
		return
	
	get_tree().set_network_peer(host)
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	_set_status("Waiting for player...")


func _on_JoinButton_pressed():
	var ip = address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid")
		return
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	_set_status("Connecting...")
