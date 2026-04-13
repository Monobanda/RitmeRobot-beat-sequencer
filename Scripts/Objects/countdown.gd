extends Node2D
@onready var timer:Timer =$Timer
@onready var label:Label = $Label
var time:float
var delay = 0.70

func _ready() -> void:
	GameComposer.start_countdown.connect(start_countdown)
	timer.timeout.connect(_timeout)

func start_countdown(max_time,note_length):
	timer.wait_time = note_length
	timer.start(note_length)
	time = max_time +delay
	GameComposer.loop_completed.connect(on_loop_completed)
	var seconds:int = time
	label.text = str(seconds)
	visible = true

func stop_countdown():
	visible=false
	label.text = ""

func on_loop_completed():
	timer.stop()
	stop_countdown()
	GameComposer.loop_completed.disconnect(on_loop_completed)

func _timeout():
	time -= timer.wait_time
	var seconds:int = time
	label.text = str(seconds)
