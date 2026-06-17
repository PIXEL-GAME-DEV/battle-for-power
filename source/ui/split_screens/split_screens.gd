extends Control


signal player_joined(player)
signal player_left(player)


const MAX_PLAYERS = 9
const PLAYER_SCREEN_SCENE = preload("res://source/ui/player_screen/player_screen.tscn")


# map from player integer to dictionary of data
# the existence of a key in this dictionary means this player is joined.
# use get_player_data() and set_player_data() to use this dictionary.
var player_data: Dictionary = {}

# map from player integer to the player node
var player_nodes = {}


@onready var grid_container: GridContainer = $GridContainer


func _ready():
	player_joined.connect(spawn_player)
	player_left.connect(delete_player)


func _process(_delta: float):
	handle_join_input()


func join(device: int):
	var player = next_player()
	if player >= 0:
		# initialize default player data here
		# "team" and "car" are remnants from my game just to provide an example
		player_data[player] = {
			"device": device,
			"team":0,
			"car":"muscle",
		}
		player_joined.emit(player)


func leave(player: int):
	if player_data.has(player):
		player_data.erase(player)
		player_left.emit(player)


func get_player_count():
	return player_data.size()


func get_player_indexes():
	return player_data.keys()


func get_player_device(player: int) -> int:
	return get_player_data(player, "device")


# get player data.
# null means it doesn't exist.
func get_player_data(player: int, key: StringName):
	if player_data.has(player) and player_data[player].has(key):
		return player_data[player][key]
	return null


# set player data to get later
func set_player_data(player: int, key: StringName, value: Variant):
	# if this player is not joined, don't do anything:
	if !player_data.has(player):
		return

	player_data[player][key] = value


# call this from a loop in the main menu or anywhere they can join
# this is an example of how to look for an action on all devices
func handle_join_input():
	for device in get_unjoined_devices():
		if MultiplayerInput.is_action_just_pressed(device, "join"):
			join(device)


# to see if anybody is pressing the "start" action
# this is an example of how to look for an action on all players
# note the difference between this and handle_join_input(). players vs devices.
func someone_wants_to_start() -> bool:
	for player in player_data:
		var device = get_player_device(player)
		if MultiplayerInput.is_action_just_pressed(device, "start"):
			return true
	return false


func is_device_joined(device: int) -> bool:
	for player_id in player_data:
		var d = get_player_device(player_id)
		if device == d: return true
	return false


# returns a valid player integer for a new player.
# returns -1 if there is no room for a new player.
func next_player() -> int:
	for i in MAX_PLAYERS:
		if !player_data.has(i): return i
	return -1


# returns an array of all valid devices that are *not* associated with a joined player
func get_unjoined_devices():
	var devices = Input.get_connected_joypads()

	# also consider keyboard player
	devices.append(-1)

	# filter out devices that are joined:
	return devices.filter(func(device): return !is_device_joined(device))




func spawn_player(player: int):
	# create the player node
	var player_node = PLAYER_SCREEN_SCENE.instantiate()
	player_node.leave.connect(on_player_leave)
	player_nodes[player] = player_node

	# let the player know which device controls it
	var device = get_player_device(player)
	player_node.init(player, device)

	# add the player to the tree
	grid_container.add_child(player_node)


func delete_player(player: int):
	player_nodes[player].queue_free()
	player_nodes.erase(player)


func on_player_leave(player: int):
	# just let the player manager know this player is leaving
	# this will, through the player manager's "player_left" signal,
	# indirectly call delete_player because it's connected in this file's _ready()
	leave(player)
