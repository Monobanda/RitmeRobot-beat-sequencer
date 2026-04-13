extends Node2D
@onready var ring:Sprite2D= $Ring
@onready var filling:Sprite2D =$Filling
@export var resource:beat_ring_button_resource
@export var button_scale:Vector2 = Vector2(0.4,0.4)
var back_up_player:AudioStreamPlayer 

var index:int = 0
var active:bool = false
var audio_backup:bool = false

#Method meant to setup the button, get the color for items in the button and connect any signals that need to be connected.
#Should more items come to the button that need to be colored, for loop should be used instead.
func _ready() -> void:
	_get_index()
	scale = button_scale
	ring.texture = resource.Empty
	filling.texture = resource.Filled
	GameComposer.use_back_up.connect(_on_audio_back_up)
	rotate_based_on_index()

#When pressing the button we set it active, true or false, and fill it in true or false
func _on_texture_button_pressed() -> void:
	active = !active
	filling.visible= active
	ring.visible = !active
	GameComposer.change_note_active_status.emit(resource.type_ring,index)

#This signal connection is going to tell the system to play when this beat button gets hit by the needle
func _on_area_2d_area_entered(_area: Area2D) -> void:
	if !active: return
	if audio_backup:
		back_up_player.play(0)

#This method is meant to be called should anything go wrong with the audio system. This is an easy back up to play one sound from the resource
func _on_audio_back_up():
	if(back_up_player == null):
		back_up_player= AudioStreamPlayer.new()
		back_up_player.bus=resource.get_bus_name()
		add_child(back_up_player)
		match resource.type_ring:
			beat_ring_button_resource.ring_types.KLAP:
				back_up_player.stream = resource.back_up_bank.klap
			beat_ring_button_resource.ring_types.STOMP:
				back_up_player.stream = resource.back_up_bank.kick
			beat_ring_button_resource.ring_types.HIHAT:
				back_up_player.stream = resource.back_up_bank.hihat
			beat_ring_button_resource.ring_types.SNARE:
				back_up_player.stream = resource.back_up_bank.snare
	audio_backup = true

#This func gets the index based on the position of this object in the list, needed for which note to set active/inactive
func _get_index():
	for c in get_parent().get_children():
		if c == self:
			break
		index+=1

#This func rotates the object based on the index that we are.
func rotate_based_on_index():
	var degree:float = 360.0 / get_parent().get_child_count() as float
	rotation_degrees = degree * index
