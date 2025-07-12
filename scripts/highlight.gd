extends Control

@export var scale_multiplier: float = 1.1
@export var transition_duration: float = 0.2

var center_pivot: Vector2
var original_size: Vector2
var tween: Tween = null

func _ready() -> void:
	center_pivot = Vector2(global_position.x + (size.x / 2), global_position.y + (size.y / 2))
	original_size = size

func _on_button_down() -> void:
	if tween != null and tween.is_valid() and tween.is_running():
		tween.kill()
	
	tween = create_tween().set_parallel()
	
	tween.tween_property(self, 'size', original_size, 0.1)
	tween.tween_property(self, 'global_position', Vector2(center_pivot.x - (original_size.x / 2), center_pivot.y - (original_size.y / 2)), 0.1)

func _on_button_up() -> void:
	if tween != null and tween.is_valid() and tween.is_running():
		tween.kill()
	
	tween = create_tween().set_parallel()
	
	tween.tween_property(self, 'size', original_size * 1.1, 0.1)
	tween.tween_property(self, 'global_position', Vector2(center_pivot.x - (original_size.x / 2 * scale_multiplier), center_pivot.y - (original_size.y / 2 * scale_multiplier)), 0.1)

func _on_mouse_entered() -> void:
	if tween != null and tween.is_valid() and tween.is_running():
		tween.kill()
	
	tween = create_tween().set_parallel()
	
	tween.tween_property(self, 'size', original_size * scale_multiplier, transition_duration)
	tween.tween_property(self, 'global_position', Vector2(center_pivot.x - (original_size.x / 2 * scale_multiplier), center_pivot.y - (original_size.y / 2 * scale_multiplier)), transition_duration)

func _on_mouse_exited() -> void:
	if tween != null and tween.is_valid() and tween.is_running():
		tween.kill()
	
	tween = create_tween().set_parallel()
	
	tween.tween_property(self, 'size', original_size, transition_duration)
	tween.tween_property(self, 'global_position', Vector2(center_pivot.x - (original_size.x / 2), center_pivot.y - (original_size.y / 2)), transition_duration)
