extends Node2D

var eyes_packed_scene: PackedScene = preload('res://instances/eyes.tscn')
var small_hand: CompressedTexture2D = preload('res://sprites/cactus/hand/small.png')
var medium_hand: CompressedTexture2D = preload('res://sprites/cactus/hand/medium.png')
var big_hand: CompressedTexture2D = preload('res://sprites/cactus/hand/big.png')

@onready var face: Sprite2D = $Face

func set_phase(phase: int) -> void:
	var face_texture_path: String = 'res://sprites/cactus/face/phase_' + str(phase) + '.png'
	
	if ResourceLoader.exists(face_texture_path):
		face.texture = load(face_texture_path)
	
	if phase >= 4 and phase <= 10:
		var animated_blinking_eyes_sprite: AnimatedSprite2D = face.get_node_or_null('BlinkingEyes')
		var hand_sprite: Sprite2D = get_node_or_null('Hand')
		
		if animated_blinking_eyes_sprite == null:
			animated_blinking_eyes_sprite = eyes_packed_scene.instantiate()
			face.add_child(animated_blinking_eyes_sprite)
		
		if hand_sprite == null:
			hand_sprite = Sprite2D.new()
			
			hand_sprite.name = 'Hand'
			hand_sprite.position = Vector2(78.0, 12.0)
			hand_sprite.scale = Vector2.ONE * 12.0
			
			add_child(hand_sprite)
		
		if phase == 4:
			animated_blinking_eyes_sprite.play('small')
			hand_sprite.texture = small_hand
		elif phase >= 5 and phase <= 6:
			
			if phase == 5:
				animated_blinking_eyes_sprite.play('medium')
			elif phase == 6:
				animated_blinking_eyes_sprite.play('big')
			
			hand_sprite.texture = medium_hand
		elif phase >= 7 and phase <= 10:
			animated_blinking_eyes_sprite.play('large')
			hand_sprite.texture = big_hand
	else:
		return
