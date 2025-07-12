extends Panel

@onready var main: Node2D = get_tree().get_root().get_child(1)

func _on_confirm_pressed() -> void:
	if main != null:
		main.sell_plant()
		main.pauseable.process_mode = Node.PROCESS_MODE_INHERIT
		queue_free()

func _on_cancel_button_pressed() -> void:
	main.pauseable.process_mode = Node.PROCESS_MODE_INHERIT
	queue_free()
