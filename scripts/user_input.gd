extends Panel

@onready var garden: Node2D = get_tree().get_root().get_child(1)
@onready var user_input: LineEdit = $LineEdit

func confirm() -> void:
	if len(user_input.text) >= 1 and len(user_input.text) <= 8:
		garden.get_node('Pauseable/FlowerPot' + str(garden.plant_index)).insert_plant(user_input.text)
		cancel()

func _on_line_edit_text_changed(new_text: String) -> void:
	if len(new_text) >= 1 and len(new_text) <= 8:
		$Label2.text = 'Passed'
		$Label2.modulate = Color.GREEN
	else:
		$Label2.text = 'Rejected'
		$Label2.modulate = Color.RED

func cancel() -> void:
	garden.resume()
	queue_free()
