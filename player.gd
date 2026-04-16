# This file was written by Gabriel Foust
class_name Player
extends Node2D

var move_distance = 64
var move_time = 0.25

@onready
var animated_sprite = $AnimatedSprite2D

signal move_finished()

var can_move = true

func move_in_direction(dir: String):
	var new_position = position
	var animation_name

	if dir == "move_left":
		new_position.x -= move_distance
		if Input.is_action_pressed("moonwalk"):
			animation_name = "move_right"
		else:
			animation_name = "move_left"

	elif dir == "move_right":
		new_position.x += move_distance
		if Input.is_action_pressed("moonwalk"):
			animation_name = "move_left"
		else:
			animation_name = "move_right"

	elif dir == "move_up":
		new_position.y -= move_distance
		animation_name = "move_up"

	elif dir == "move_down":
		new_position.y += move_distance
		animation_name = "move_down"

	if position != new_position:
		# position = new_position
		var tween = create_tween()
		tween.tween_property(self, "position", new_position, move_time)
		animated_sprite.play(animation_name)
		tween.finished.connect(on_tween_finished)
		can_move = false
		return true
	else:
		return false


func stop_moving():
	animated_sprite.stop()


func on_tween_finished():
	move_finished.emit()


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
