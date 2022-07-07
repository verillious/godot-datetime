extends Control

var datetime = DateTime.now()

var _delta_index := 0.0
var _speed := 1.0


func _process(delta: float) -> void:
	_delta_index += delta
	if _delta_index >= 1.0:
		datetime.add_seconds(1)
		_delta_index = 0.0

	$CenterContainer/VBoxContainer/Label.text = datetime.get_datetime_string()
