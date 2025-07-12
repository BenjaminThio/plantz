extends TextureButton

var cactus_packed_scene: PackedScene = preload('res://instances/cactus.tscn')
var enchanted_glowing_particles_packed_scene: PackedScene = preload('res://instances/enchanted_glowing_particles.tscn')
var user_input: PackedScene = preload('res://instances/user_input.tscn')

@onready var garden = get_tree().get_root().get_child(1)
@onready var hotbar: NinePatchRect = garden.get_node('Pauseable/Hotbar')

func _process(_delta: float) -> void:
	var enchanted_glowing_particles: GPUParticles2D = get_node_or_null('EnchantedGlowingParticles')
	
	if enchanted_glowing_particles != null:
		enchanted_glowing_particles.position = Vector2(position.x + (size.x / 2), position.y + (size.y / 2))

func insert():
	if garden.plants[garden.plant_index] == null:
		garden.add_child(user_input.instantiate())
		garden.pause()

func insert_plant(plant_name: String):
	var plant: Plant = garden.plants[garden.plant_index]
	
	if plant == null:
		if hotbar.slots[hotbar.selected_slot_index] != null and hotbar.slots[hotbar.selected_slot_index].quantity - 1 >= 0:
			hotbar.slots[hotbar.selected_slot_index].quantity -= 1
			hotbar.update_slots()
		else:
			return
		
		var cactus: Node2D = cactus_packed_scene.instantiate()
		
		@warning_ignore("int_as_enum_without_cast")
		garden.plants[garden.plant_index] = Plant.new(0, plant_name)
		add_child(cactus)
		garden.update_phase()
		garden.update_name()

func enchanted():
	var enchanted_glowing_particles: GPUParticles2D = get_node_or_null('EnchantedGlowingParticles')
	
	if enchanted_glowing_particles == null:
		add_child(enchanted_glowing_particles_packed_scene.instantiate())

func unenchanted():
	var enchanted_glowing_particles: GPUParticles2D = get_node_or_null('EnchantedGlowingParticles')
	
	if enchanted_glowing_particles != null:
		enchanted_glowing_particles.queue_free()
