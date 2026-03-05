# This file was written by Gabriel Foust

extends Node2D

var move_distance = 64
var move_time = 0.5

@onready
var animated_sprite = $AnimatedSprite2D

var can_move = true

func _input(event: InputEvent) -> void:
	if not can_move:
		return
	
	var new_position = position
	var animation_name
	
	if event.is_action_pressed("move_left"):
		new_position.x -= move_distance
		if Input.is_action_pressed("moonwalk"):
			animation_name = "move_right"
		else:
			animation_name = "move_left"
			
	if event.is_action_pressed("move_right"):
		new_position.x += move_distance
		if Input.is_action_pressed("moonwalk"):
			animation_name = "move_left"
		else:
			animation_name = "move_right"
		
	if event.is_action_pressed("move_up"):
		new_position.y -= move_distance
		animation_name = "move_up"
		
	if event.is_action_pressed("move_down"):
		new_position.y += move_distance
		animation_name = "move_down"
	
	if position != new_position:
		# position = new_position	
		var tween = create_tween()
		tween.tween_property(self, "position", new_position, move_time)
		animated_sprite.play(animation_name)
		tween.finished.connect(on_tween_finished)
		can_move = false


func on_tween_finished():
	animated_sprite.stop()
	can_move = true
	

func get_tile_coords_x():
	var x_coord = position.x / 64
	return x_coord


func get_tile_coords_y():
	var y_coord = position.y / 64
	return y_coord
