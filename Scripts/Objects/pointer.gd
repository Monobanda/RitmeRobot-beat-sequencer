extends Sprite2D
var active:bool = false
var seconds:float
var note_length :float
var notes_per_beat

#This func connects mutliple signals
func _ready() -> void:
	GameComposer.change_play_state.connect(_on_change_play_state)
	GameComposer.set_notes_per_beat.connect(on_set_notes_per_beat)
	GameComposer.set_seconds.connect(on_set_seconds)
	GameComposer.set_note_length.connect(on_set_notes_length)

#This func changes our position based on seconds, note_length and note_per_beat
func _process(_delta: float) -> void:
	if note_length == 0.0:
		GameComposer.retrieve_note_length.emit()
		GameComposer.set_note_length.disconnect(on_set_notes_length)
	if notes_per_beat == null:
		GameComposer.retrieve_notes_per_beat.emit()
		GameComposer.set_notes_per_beat.disconnect(on_set_notes_per_beat)
	if active:
		GameComposer.retrieve_seconds.emit()
		var rotation_factor:float = (-1+(seconds  / note_length )) / notes_per_beat
		var calc_rotation_degree:float  = rotation_factor * 360  - 7
		rotation_degrees = calc_rotation_degree
#This is for the connected signal Change_play_state
func _on_change_play_state(state):
	active = state

#This is for the connected signal set_seconds
func on_set_seconds(_sec):
	seconds = _sec

#This is for the connected signal set_note_length
func on_set_notes_length(_note_length):
	note_length = _note_length

#This is for the connected signal set_notes_per_beat
func on_set_notes_per_beat(_notes):
	notes_per_beat = _notes
