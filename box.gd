@tool
extends Node2D

var move_distance = 64
var move_time = 0.25

signal move_finished(box)

enum Shade { BROWN = 1, RED, BLUE, GREEN, GRAY }

@onready var sprite: Sprite2D = $Sprite2D

@export var shade = Shade.BROWN:
	set(value):
		shade = value
		_set_frame()
		
		
func _set_frame():
	if sprite:
		sprite.frame_coords.x = shade


func _ready():
	_set_frame()

func move_in_direction(dir: String):
	var new_position = position
	
	if dir == "move_left":
		new_position.x -= move_distance
			
	elif dir == "move_right":
		new_position.x += move_distance
		
	elif dir == "move_up":
		new_position.y -= move_distance
		
	elif dir == "move_down":
		new_position.y += move_distance
	
	if position != new_position:
		# position = new_position	
		var tween = create_tween()
		tween.finished.connect(on_tween_finished)
		tween.tween_property(self, "position", new_position, move_time)
	


func on_tween_finished():
	move_finished.emit(self)
	

func get_tile_coords_x():
	var x_coord = round(position.x / 64)
	return x_coord


func get_tile_coords_y():
	var y_coord = round(position.y / 64)
	return y_coord


func get_tile_coords():
	var x_coord = round(position.x / 64)
	var y_coord = round(position.y / 64)
	return Vector2(x_coord, y_coord)


func shine():
	$CPUParticles2D.emitting = true
	$AudioStreamPlayer.play()
