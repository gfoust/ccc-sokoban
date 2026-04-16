extends CanvasLayer

signal win_finished


func go():
	show()
	$WinMusic.play()
	await get_tree().create_timer(3.0).timeout
	win_finished.emit()
