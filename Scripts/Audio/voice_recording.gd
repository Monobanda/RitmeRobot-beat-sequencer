extends Node

@export var play_button:Node2D

var effect:AudioEffectRecord
var recording
var rec_time:float = 4
var rec_button:Button
var back_up_effect:AudioEffectCapture
var is_recording:bool
var data:Array
var back_up:bool = false
var capture_mix_rate:float
var count_down :Timer = Timer.new()
var note_length
var notes_per_beat

#Ready checks if we need to use the record or capture effect
func _ready() -> void:
	GameComposer.set_note_length.connect(on_set_note_Length)
	GameComposer.set_notes_per_beat.connect(on_set_notes_per_beat)
	if OS.get_model_name() == "GenericDevice":
		setup_effect_backup()
	else:
		setup_effect()

func _process(_delta: float) -> void:
	if is_recording:
		var available_frames = back_up_effect.get_frames_available()
		if available_frames > 0:
			var buffer = back_up_effect.get_buffer(available_frames)  # Get only the required frames
			for frame in buffer:
				data.append(frame.x)  # Left channel

#This gets the correct effect, in this case record effect
func setup_effect():
	var idx = AudioServer.get_bus_index("Microphone")
	effect = AudioServer.get_bus_effect(idx, 1)

#This gets the capture effect, in case the record effect isn't usable
func setup_effect_backup():
	var idx = AudioServer.get_bus_index("Microphone")
	back_up_effect = AudioServer.get_bus_effect(idx, 0)
	capture_mix_rate = AudioServer.get_input_mix_rate()
	back_up = true

#We start the recording on either the capture (back_up) effect or the recording effect
func _start_recording():
	GameComposer.change_play_state.emit(false)
	if back_up:
		if not is_recording:
			back_up_effect.clear_buffer()
			data.clear()
			is_recording = true
	else:
		effect.set_recording_active(true)
	#$"Voice button".text = "Stop"
	_create_timer()

#After the timer has ended we stop the recordings and send the file via the composer to the track
func _on_timer_timeout():
	if back_up:
		is_recording = false
		GameComposer.set_rec_synth.emit(convert_to_wav(data),audio_track_resource.synths.GREEN)
		#$"Voice button".text = "Record"
		$"Voice button/Empty".visible = false
		$"Voice button/Recorded".visible = true
		return
	
	if effect.is_recording_active():
		recording = effect.get_recording()
		effect.set_recording_active(false)
		GameComposer.set_rec_synth.emit(recording, audio_track_resource.synths.GREEN)
		$"Voice button/Empty".visible = false
		$"Voice button/Recorded".visible = true
		#$"Voice button".text = "Record"

#This sets the record button
func _on_set_rec_button(button):
	rec_button = button

#This creates the timer based on the note_length * the amount of notes
func _create_timer():
	if note_length == null:
		GameComposer.retrieve_note_length.emit()
		GameComposer.set_note_length.disconnect(on_set_note_Length)
	if notes_per_beat == null:
		GameComposer.retrieve_notes_per_beat.emit()
		GameComposer.set_notes_per_beat.disconnect(on_set_notes_per_beat)
	rec_time = note_length * notes_per_beat
	get_tree().create_timer(rec_time).timeout.connect(_on_timer_timeout)

#This is for the signal set_note_length, this is so we can use it in create timer
func on_set_note_Length(length):
	note_length = length

#This is for the signal set_notes_per_beat, this is so we can use it in create timer
func on_set_notes_per_beat(notes):
	notes_per_beat = notes

#Code taken from https://github.com/godotengine/godot/issues/102316
func convert_to_wav(audio_data: PackedFloat32Array) -> AudioStreamWAV:
	var wav_stream = AudioStreamWAV.new()
	
	# Convert from float (-1.0 to 1.0) to 16-bit PCM (-32768 to 32767)
	var pcm_data = PackedByteArray()
	for i in range(0, audio_data.size()):  # Process stereo pairs
		var left_sample = int(clamp(audio_data[i] * 32767.0, -32768, 32767))

		# Append left sample (little-endian format)
		pcm_data.append(left_sample & 0xFF)
		pcm_data.append((left_sample >> 8) & 0xFF)

	wav_stream.format = AudioStreamWAV.FORMAT_16_BITS
	wav_stream.mix_rate = capture_mix_rate
	print("mix rate = %s" % capture_mix_rate)
	wav_stream.stereo = false  # Enable stereo playback
	wav_stream.data = pcm_data  # Convert to byte array

	return wav_stream

#This is what creates the timer, for a slight delay, that starts the recording, it also disconnects a signal
func record_on_Sequencer():
	get_tree().create_timer(0.1).timeout.connect(_start_recording)
	GameComposer.stop_all_players.emit()
	GameComposer.loop_completed.disconnect(record_on_Sequencer)

#This is the connected signal for the button, when you press it, it starts the system for recording
func _on_voice_button_pressed() -> void:
	GameComposer.prepare_for_recording.emit()
	GameComposer.loop_completed.connect(record_on_Sequencer)
	GameComposer.change_play_state.emit(true)
	#$"Voice button".text = "Waiting"
