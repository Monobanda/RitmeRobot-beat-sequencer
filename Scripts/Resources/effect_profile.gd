extends Resource
class_name effect_profile

@export var pitch_shift: float
@export var distortion_db: float
@export var phaser: float
@export var delay: float
@export var reverb: float

func apply(bus_index: int) -> void:
	var pitch = AudioServer.get_bus_effect(bus_index, 0) as AudioEffectPitchShift
	AudioServer.set_bus_effect_enabled(bus_index, 0, pitch_shift > 0)
	pitch.pitch_scale = pitch_shift if pitch_shift > 0 else 1.0
	
	var distortion = AudioServer.get_bus_effect(bus_index, 1) as AudioEffectDistortion
	AudioServer.set_bus_effect_enabled(bus_index, 1, distortion_db > 0)
	distortion.pre_gain = distortion_db
	
	var phaser_effect = AudioServer.get_bus_effect(bus_index, 2) as AudioEffectPhaser
	AudioServer.set_bus_effect_enabled(bus_index, 2, phaser > 0)
	if phaser > 0:
		phaser_effect.rate_hz = phaser
	
	# var delay_effect = AudioServer.get_bus_effect(bus_index, 3) as AudioEffectDelay
	# AudioServer.set_bus_effect_enabled(bus_index, 3, delay > 0)
	# if delay > 0:
	#     delay_effect.tap_1_delay_ms = delay
	#     delay_effect.tap_2_delay_ms = delay * 2
	
	var reverb_effect = AudioServer.get_bus_effect(bus_index, 4) as AudioEffectReverb
	AudioServer.set_bus_effect_enabled(bus_index, 4, reverb > 0)
	if reverb > 0:
		reverb_effect.room_size = reverb
