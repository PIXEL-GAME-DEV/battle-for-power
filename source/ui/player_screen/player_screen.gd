extends Control


signal leave

var player: int
var input: DeviceInput

@onready var sub_viewport: SubViewport = $RescaleContainer/SubViewportContainer/SubViewport
@onready var camera_3d: Camera3D = $RescaleContainer/SubViewportContainer/SubViewport/Camera3D


func _ready():
	pass


func _process(delta: float):
	var move_input := input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var vertical_input := input.get_axis("move_down", "move_up")
	var turn_input := input.get_axis("turn_left", "turn_right")
	var move := Vector3(move_input.x, vertical_input, move_input.y)
	camera_3d.global_position += camera_3d.global_basis.x * move.x * delta
	camera_3d.global_position += camera_3d.global_basis.y * move.y * delta
	camera_3d.global_position += camera_3d.global_basis.z * move.z * delta
	camera_3d.rotation.y -= turn_input * delta

	# let the player leave by pressing the "join" button
	if input.is_action_just_pressed("join"):
		# an alternative to this is just call PlayerManager.leave(player)
		# but that only works if you set up the PlayerManager singleton
		leave.emit(player)


# call this function when spawning this player to set up the input object based on the device
func init(player_num: int, device: int):
	player = player_num

	# in my project, I got the device integer by accessing the singleton autoload PlayerManager
	# but for simplicity, it's not an autoload in this demo.
	# but I recommend making it a singleton so you can access the player data from anywhere.
	# that would look like the following line, instead of the device function parameter above.
	# var device = PlayerManager.get_player_device(player)
	input = DeviceInput.new(device)

	#$Player.text = "%s" % player_num
