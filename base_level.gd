extends Node2D

########
# Objects from our scene that we want to be able to access
# (so we store them in variables)

@onready
var player: Player = $Player

@onready
var walls: TileMapLayer = $Map/Walls

@onready
var targets: TileMapLayer = $Map/Targets

########
# Other things our game needs to keep track of

var goals_to_win := 0

var moving_things_count = 0


########
# Functions that Godot will call for us

# Called one time once the scene is ready
func _ready():
	# Listen for player's "move_finished" signal
	player.move_finished.connect(on_player_move_finished)
	# Listen for all the boxes' "move_finished" signals
	for box in get_tree().get_nodes_in_group("boxes"):
		box.move_finished.connect(on_box_move_finished)
	# Count how many targets there are
	goals_to_win = targets.get_used_cells().size()


# Called any time the user presses (or releases) a key
func _input(_event: InputEvent):
	check_for_move()


########
# Functions that decide who moves where and when

# Check to see if arrow key is being pressed and move the player if it is
func check_for_move():
	if moving_things_count > 0:
		return
		
	var dir
	if Input.is_action_pressed("move_left"):
		dir = "move_left"
	if Input.is_action_pressed("move_right"):
		dir = "move_right"
	if Input.is_action_pressed("move_up"):
		dir = "move_up"
	if Input.is_action_pressed("move_down"):
		dir = "move_down"

	if dir == null:
		# The user isn't pressing any keys
		player.stop_moving()
	else:
		var moved_boxes = player_can_move_in_direction(dir)
		if moved_boxes == null:
			# We can't move in the direction the user wants to go
			player.stop_moving()
		else:
			# We can move in the direction the user wants us to go
			player.move_in_direction(dir)
			moving_things_count += 1
			for box in moved_boxes:
				if targets.get_cell_tile_data(box.get_tile_coords()):
					goals_to_win += 1
				box.move_in_direction(dir)
				moving_things_count += 1


# return the tile data for the given coordinates
#     or null if there is no tile there
func wall_at_coords(coords):
	return walls.get_cell_tile_data(coords)


# return the box for the given coordinates
#     or null if there is no box there
func box_at_coords(coords):
	for box in get_tree().get_nodes_in_group("boxes"):
		var box_coords = box.get_tile_coords()
		if box_coords == coords:
			return box
	return null


# return true if box can move in the given direction
#     or false if it cannot
func box_can_move_in_direction(box, dir):
	var box_coords = box.get_tile_coords()
	var destination_coords = coords_in_dir(box_coords, dir)
	if wall_at_coords(destination_coords) or box_at_coords(destination_coords):
		return false
	else:
		return true
		

# return the list of boxes the player would push if he goes in the given direction
#     or null if the player cannot move in that direction
#        (the list will be empty if the player does not push any boxes)
func player_can_move_in_direction(dir):
	var player_coords = player.get_tile_coords()
	var destination_coords = coords_in_dir(player_coords, dir)
	
	var wall = wall_at_coords(destination_coords)
	if wall != null:
		return null # we cannot move: there is a wall there
		
	var box = box_at_coords(destination_coords)
	if box != null:
		if box_can_move_in_direction(box, dir):
			return [box] # a list of one thing: the box we're pushing
		else:
			return null # we cannot move: there is a box there we cannot push
	
	return [] # an empty list: we're not pushing any boxes


func coords_in_dir(coords: Vector2, dir: String):
	if dir == "move_left":
		return Vector2(coords.x - 1, coords.y)
	if dir == "move_right":
		return Vector2(coords.x + 1, coords.y)
	if dir == "move_up":
		return Vector2(coords.x, coords.y - 1)
	if dir == "move_down":
		return Vector2(coords.x, coords.y + 1)
	return coords


func on_player_move_finished():
	moving_things_count -= 1
	check_for_move()


func on_box_move_finished(box):
	if targets.get_cell_tile_data(box.get_tile_coords()):
		goals_to_win -= 1
		print("Goal reached! %d left." % [goals_to_win])
	moving_things_count -= 1
	check_for_move()
