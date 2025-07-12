extends Panel

@onready var garden: Node2D = get_tree().get_root().get_child(1)
@onready var hotbar = garden.get_node('Pauseable/Hotbar')

const MAX_ITEM_QUANTITY: int = 64

enum ITEM {
	CACTUS_SEED
}

const COST: Dictionary = {
	'cactus_seed': 1
}

func buy(item_index: ITEM = ITEM.CACTUS_SEED) -> void:
	var item_name: String = ITEM.keys()[item_index].to_lower()
	var coins: int = garden.coins
	
	if coins - COST[item_name] < 0:
		return
	
	for slot_index in range(len(hotbar.slots)):
		var slot = hotbar.slots[slot_index]
		
		if slot != null and slot.item == item_name and slot.quantity + 1 <= MAX_ITEM_QUANTITY:
			garden.coins -= COST[item_name]
			slot.quantity += 1
			garden.update_coins()
			hotbar.update_slots()
			return
	
	for slot_index in range(len(hotbar.slots)):
		var slot = hotbar.slots[slot_index]
		
		if slot == null:
			garden.coins -= COST[item_name]
			hotbar.slots.remove_at(slot_index)
			hotbar.slots.insert(slot_index, {'item': ITEM.keys()[item_index].to_lower(), 'quantity': 1})
			garden.update_coins()
			hotbar.update_slots()
			return

func cancel() -> void:
	garden.pauseable.process_mode = Node.PROCESS_MODE_INHERIT
	queue_free()
