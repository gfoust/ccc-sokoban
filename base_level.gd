extends Node2D

@onready
var player: Player = $Player

@onready
var walls: TileMapLayer = $Walls

var player_can_move = true


func _ready():
	player.move_finished.connect(on_player_move_finished)


func _input(event: InputEvent):
	if not player_can_move:
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

#===============================================================================
# CHANGED CODE

	if dir != null:
		var move_result = player_can_move_in_direction(dir)
		if move_result != null:
			player_can_move = false
			player.move_in_direction(dir)
			for box in move_result:
				box.move_in_direction(dir)


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


# REMAINING CODE IS THE SAME	
#===============================================================================

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
	player_can_move = true;
