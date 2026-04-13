extends Node

class_name audio_composer

@export_category("Ring Players")
@export var stomp_ring_players :Array[AudioStreamPlayer]
@export var klap_ring_players :Array [AudioStreamPlayer]
@export var snare_ring_players :Array [AudioStreamPlayer]
@export var hihat_ring_players :Array [AudioStreamPlayer]
@export var green_synth:Array[AudioStreamPlayer]
@export_category("Audio Sources")
@export var bank:audio_bank

var green_rec
var green_index = 0
var purple_index = 1
@export var backup_bank:audio_bank 
var stomp_ring:Node2D
var klap_ring:Node2D
var hihat_ring:Node2D
var snare_ring:Node2D

var primary_player = 0
var recording_player = 2



func _ready() -> void:
	GameComposer.set_audio_composer.emit(self)
	GameComposer.set_rec_synth.connect(_on_set_rec_synth)
	GameComposer.play_synth.connect(_on_play_synth)
	GameComposer.stop_synth.connect(_on_stop_synth)
	GameComposer.play_ring_type.connect(_on_play)
	GameComposer.stop_all_players.connect(_on_stop_all_player)
	name = "audio_composer"
	if bank != null:
		_fill_players(bank)
	else:
		_fill_players(backup_bank)

#Play audio based on the ring type given
func _on_play(ring_type:beat_ring_button_resource.ring_types):
	match ring_type:
		beat_ring_button_resource.ring_types.KLAP:
			_set_player_volumes()
			klap_ring_players[primary_player].play(0)
		beat_ring_button_resource.ring_types.STOMP:
			_set_player_volumes()
			stomp_ring_players[primary_player].play(0)
		beat_ring_button_resource.ring_types.SNARE:
			_set_player_volumes()
			snare_ring_players[primary_player].play(0)
		beat_ring_button_resource.ring_types.HIHAT:
			_set_player_volumes()
			hihat_ring_players[primary_player].play(0)

#TODO This func sets the volumes of the places based on the values of the mixer
func _set_player_volumes():
	pass

#TODO this func needs to get the values from the mixer
func _get_players_volumes():
	pass

#Only to be used during backup, this does the setup for the playes should they not exist already
func _setup_players(ring_player, bus):
	ring_player.resize(3)
	var i = 0
	for c in ring_player:
		c = AudioStreamPlayer.new()
		c.set_bus(bus)
		ring_player.set(i,c)
		i+=1
		add_child(c)

#This func gives the players the information they need to play the correct file based on the bank
func _fill_players(_bank):
	stomp_ring_players.get(primary_player).stream =_bank.kick
	klap_ring_players.get(primary_player).stream =_bank.klap
	snare_ring_players.get(primary_player).stream =_bank.snare
	hihat_ring_players.get(primary_player).stream =_bank.hihat

#This sets the stream and creates the synth if it doesn't exist already
func _on_set_rec_synth(recording):
	green_rec = recording
	if green_synth[2] == null:
		var temp = green_synth[green_index] 
		temp = AudioStreamPlayer.new()
		temp.stream = recording
		temp.set_bus("GreenVoice")
		green_synth[green_index] = temp
		add_child(green_synth[green_index])
	else:
		green_synth[2].stream = recording

#This func starts the synth stream based on the time given
func _on_play_synth(_time):
	for c in green_synth:
		if c != null:
			c.play(_time)

#This func stops the synth from playing
func _on_stop_synth():
	for c in green_synth:
		if c != null:
			c.stop()

func _on_stop_all_player():
	print("stopped players")
	klap_ring_players[primary_player].stop()
	stomp_ring_players[primary_player].stop()
	hihat_ring_players[primary_player].stop()
	snare_ring_players[primary_player].stop()
