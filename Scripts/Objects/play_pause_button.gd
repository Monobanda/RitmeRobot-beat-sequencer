extends Node2D

var _active:bool

@onready var play_pause_button = $PlayPauseButton

signal play_button_pressed()
var seconds: float

#This func connects set_seconds signal
func _ready() -> void:
	GameComposer.set_seconds.connect(on_set_seconds)

#This is the connected signal, when we press based on our active state we either send to play or stop the sequencer and synth
func _on_play_pause_button_pressed() -> void:
	_active = !_active
	GameComposer.change_play_state.emit(_active)
	match _active:
		true:
			GameComposer.retrieve_seconds.emit()
			GameComposer.play_synth.emit(seconds,audio_track_resource.synths.GREEN)
			play_pause_button.text = "⏸️"
		false: 
			GameComposer.stop_synth.emit()
			play_pause_button.text = "▶️"
	play_button_pressed.emit()

#Was for testing
func _print_midi_info(midi_event):
	#if delay: return
	if(midi_event.message == 250):
		_on_play_pause_button_pressed()
		print("started")
	if(midi_event.message == 252):
		_on_play_pause_button_pressed()
	if(midi_event.message == 248):
		pass
			#print("this is the clock")
		#else:
			#var bps =0.0
			#var bpm = 0
			#bps =clock / 24
			#bpm = bps * 6
			#print("Your bpm is ", bpm)

#Was for testing
func _input(input_event):
	if input_event is InputEventMIDI:
		_print_midi_info(input_event)

#For the signal set_seconds
func on_set_seconds(sec):
	seconds = sec
