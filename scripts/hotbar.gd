extends NinePatchRect

var slot_packed_scene: PackedScene = preload('res://instances/slot.tscn')
var slots: Array = [
	{'item': 'cactus_seed', 'quantity': 64},
	{'item': 'cactus_seed', 'quantity': 64},
	{'item': 'cactus_seed', 'quantity': 64},
	{'item': 'cactus_seed', 'quantity': 64},
	{'item': 'cactus_seed', 'quantity': 64},
	{'item': 'cactus_seed', 'quantity': 64},
	{'item': 'cactus_seed', 'quantity': 64},
	{'item': 'cactus_seed', 'quantity': 60}
]
"""
null,
null,
null,
null,
null,
null,
null
"""
var selected_slot_index: int = 0

@onready var horizontal_box_container: HBoxContainer = $HBoxContainer

func _ready():
	update_slots()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('wheel_up') or Input.is_action_just_pressed('wheel_down'):
		if Input.is_action_just_pressed('wheel_up'):
			if selected_slot_index + 1 < len(slots):
				selected_slot_index += 1
			else:
				selected_slot_index = 0
		elif Input.is_action_just_pressed('wheel_down'):
			if selected_slot_index - 1 >= 0:
				selected_slot_index -= 1
			else:
				selected_slot_index = len(slots) - 1
		update_slots()

func update_slots():
	for child in horizontal_box_container.get_children():
		horizontal_box_container.remove_child(child)
	
	for slot_index in range(len(slots)):
		var slot: Button = slot_packed_scene.instantiate()
		
		slot.pressed.connect(func() -> void:
			selected_slot_index = slot_index
			update_slots()
		)
		
		if slot_index == selected_slot_index:
			var selected_texture: NinePatchRect = slot.get_child(0).get_child(0)
			
			selected_texture.show()
		
		if slots[slot_index] != null:
			var item_texture: TextureRect = slot.get_child(1)
			var quantity_label: Label = slot.get_child(2)
			
			item_texture.texture = load('res://sprites/items/' + slots[slot_index].item + '.png')
			quantity_label.show()
			quantity_label.text = str(slots[slot_index].quantity)
		
		horizontal_box_container.add_child(slot)
