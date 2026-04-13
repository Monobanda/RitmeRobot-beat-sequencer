extends Resource
class_name beat_ring_button_resource

#@export var default_audio: AudioStream
@export var back_up_bank:audio_bank 
@export var type_ring: ring_types
enum ring_types{
	KLAP,
	STOMP,
	HIHAT,
	SNARE,
	GUITAR
}

@export_category("Assets")
@export_subgroup("Empty")
@export var Empty:Texture = preload("res://Assets/Sprites/New Assets/Art Assets/Shapes/Outlines/SHAPES_Pink_Empty.png")
@export_subgroup("filled")
@export var Filled:Texture = preload("res://Assets/Sprites/New Assets/Art Assets/Shapes/Filled/SHAPES_Pink_ROUND.png")
@export_category("")

func get_bus_name():
	var bus_name:String
	match type_ring:
		ring_types.KLAP:
			bus_name="Ring1"
		ring_types.STOMP:
			bus_name="Ring0"
		ring_types.HIHAT:
			bus_name="Ring3"
		ring_types.SNARE:
			bus_name="Ring2"
	return bus_name
