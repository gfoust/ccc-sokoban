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

	if dir and player_can_move_in_direction(dir):
		player.move_in_direction(dir)
		player_can_move = false


func player_can_move_in_direction(dir):
	var player_tile_coords = Vector2(
		player.get_tile_coords_x(), 
		player.get_tile_coords_y()
	)
	var destination_tile_coords = coords_in_dir(player_tile_coords, dir)
	if walls.get_cell_tile_data(destination_tile_coords):
		return false
		
	for box in get_tree().get_nodes_in_group("boxes"):
		var box_tile_coords = Vector2(
			box.get_tile_coords_x(),
			box.get_tile_coords_y()
		)
		if box_tile_coords == destination_tile_coords:
			var box_destination_tile_coords = coords_in_dir(box_tile_coords, dir)
			if walls.get_cell_tile_data(box_destination_tile_coords):
				return false
	
	return true


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
