extends Control

var datetime = DateTime.datetime()

var _delta_index := 0.0
var _speed := 1.0


func _process(delta: float) -> void:
	_delta_index += delta
	if _delta_index >= 0.06:
		datetime.add_time(0, 0, 0, 0, 0, 1)
		_delta_index = 0.0

	$CenterContainer/VBoxContainer/Label.text = datetime.get_datetime_string()
	print()
