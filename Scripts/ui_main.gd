extends CanvasModulate

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
@onready var cam = $Camera2D

func _on_button_pressed() -> void:
	peer.create_server(6342)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	cam.enabled = false

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)


func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player")

@rpc("any_peer", "call_local") func  _del_player(id):
	get_node(str(id)).queue_free()
	


func _on_button_2_pressed() -> void:
	peer.create_client("192.168.8.151", 6342)
	multiplayer.multiplayer_peer = peer
	cam.enabled = false
