extends Node2D

enum DIRECTION {
	LEFT = -1,
	RIGHT = 1
}

@export var max_plants: int = 10
@export var tween_duration: float = 0.2

var plant_pot_packed_scene: PackedScene = preload("res://instances/flower_pot.tscn")
var cactus_packed_scene: PackedScene = preload("res://instances/cactus.tscn")
var confirmation_dialog: PackedScene = preload('res://instances/confirmation_dialog.tscn')
var shopoo_panel_packed_scene: PackedScene = preload('res://instances/shopoo_panel.tscn')

var coins: int = 10
var plant_index: int = 0
var plants: Array[Plant] = []
var is_watering: bool = false
var is_fertilizing: bool = false

@onready var pauseable: Node2D = $Pauseable
@onready var phase_label: Label = $Pauseable/PhaseLabel
@onready var coins_label: Label = $Pauseable/CoinsLabel
@onready var center_marker: Marker2D = $Pauseable/CenterMarker
@onready var left_marker: Marker2D = $Pauseable/LeftMarker
@onready var right_marker: Marker2D = $Pauseable/RightMarker
@onready var index_label: Label = $Pauseable/IndexLabel
@onready var name_label: Label = $Pauseable/NameLabel
@onready var water_progress_bar: TextureProgressBar = $Pauseable/WaterButton/TextureProgressBar

func _ready() -> void:
	for i in range(max_plants):
		plants.append(null)
	update_coins()
	update_phase()
	update_plant_pot()
	update_index()
	update_name()

func add_coins(amount: int) -> void:
	coins += amount
	update_coins()

func update_coins() -> void:
	coins_label.text = '$' + str(coins)

func update_phase() -> void:
	var plant = plants[plant_index]
	
	if plant != null:
		var phase: int = plant.phase
		var flower_pot: TextureButton = get_node('Pauseable/FlowerPot' + str(plant_index))
		var cactus: Node2D = flower_pot.get_node('Cactus')
		
		phase_label.text = 'Phase ' + str(phase)
		cactus.set_phase(phase)
		if phase == plant.MAX_PHASE:
			flower_pot.enchanted()
	else:
		phase_label.text = 'NULL'

var is_switching_plant: bool = false

func _on_direction_button_pressed(direction: DIRECTION) -> void:
	if is_watering or is_fertilizing:
		return
	
	switch_plant(direction)
	update_index()

func switch_plant(direction: DIRECTION) -> void:
	if is_switching_plant:
		return
	
	is_switching_plant = true
	
	var predicted_index: int = predict_index(plant_index, direction)
	var previous_index: int = plant_index
	
	var plant_pot: TextureButton = plant_pot_packed_scene.instantiate()
	
	plant_index = predicted_index
	
	update_name()
	
	plant_pot.name = 'FlowerPot' + str(predicted_index)
	plant_pot.global_position = (left_marker if direction == DIRECTION.LEFT else right_marker).global_position
	
	pauseable.add_child(plant_pot)
	
	if plants[predicted_index] != null:
		plant_pot.add_child(cactus_packed_scene.instantiate())
	
	update_phase()
	
	var tween: Tween = create_tween().set_parallel()
	
	tween.tween_property(plant_pot, 'global_position', center_marker.global_position, tween_duration)
	tween.tween_property(get_node('Pauseable/FlowerPot' + str(previous_index)), 'global_position', (right_marker if direction == DIRECTION.LEFT else left_marker).global_position, tween_duration)
	tween.finished.connect(
		func():
			get_node('Pauseable/FlowerPot' + str(previous_index)).queue_free()
			is_switching_plant = false
			tween.kill()
	)

func predict_index(index: int, direction: DIRECTION) -> int:
	if direction < 0:
		if index - 1 >= 0:
			index -= 1
		else:
			index = max_plants - 1
	elif direction > 0:
		if index + 1 < max_plants:
			index += 1
		else:
			index = 0
	else:
		printerr('UNEXPECTED DIRECTION')
	
	return index

func update_index():
	index_label.text = 'Slot ' + str(plant_index + 1)

func update_plant_pot():
	var plant_pot: TextureButton = plant_pot_packed_scene.instantiate()
	
	plant_pot.name = 'FlowerPot' + str(plant_index)
	plant_pot.global_position = center_marker.global_position
	
	pauseable.add_child(plant_pot)

func _on_fertilize_button_pressed() -> void:
	if plants[plant_index] != null and not is_fertilizing:
		var fertilize_animation: AnimationPlayer = get_node('Pauseable/FlowerPot' + str(plant_index) + '/FertilizerBag/AnimationPlayer')
		
		is_fertilizing = true
		fertilize_animation.play('fertilize')
		await time.sleep(pauseable, 3.0,
			func():
				plants[plant_index].is_fertilized = true
				is_fertilizing = false
		)

func update_name():
	if plants[plant_index] != null:
		name_label.text = plants[plant_index].plant_name
	else:
		name_label.text = 'NULL'

var refill_tween: Tween = null
const WATER_REFILL_DURATION: float = 5.0
const speed: float = 100.0 / WATER_REFILL_DURATION

func refill_water() -> void:
	if is_watering or water_progress_bar.value == water_progress_bar.max_value:
		return
	
	if refill_tween == null or not refill_tween.is_valid():
		refill_tween = get_tree().create_tween().bind_node(pauseable)
	
	var distance: float = water_progress_bar.max_value - water_progress_bar.value
	var water_refill_duration_left: float = distance / speed
	
	#printt(distance, speed, water_refill_duration_left)
	
	if refill_tween.is_valid():
		refill_tween.tween_property(water_progress_bar, 'value', 100.0, water_refill_duration_left)

func cancel_refill() -> void:
	if refill_tween != null and refill_tween.is_valid():
		refill_tween.kill()
		refill_tween = null

func water_plant():
	var plant: Plant = plants[plant_index]
	
	"""
	if plant != null:
		plants[plant_index].is_fertilized = true
		plant.upgrade_phase()
		update_phase()
	"""
	
	if not is_watering and plant != null:
		is_watering = true
		if plant != null:
			var water_animation: AnimationPlayer = get_node('Pauseable/FlowerPot' + str(plant_index) + '/WateringCan/AnimationPlayer')
			
			if water_animation != null:
				water_animation.play('water')
		
		#water_progress_bar.value = water_progress_bar.max_value
		get_tree().create_tween().bind_node(pauseable).tween_property(water_progress_bar, 'value', 0, 5.0).finished.connect(
			func() -> void:
				plants[plant_index].upgrade_phase()
				update_phase()
				is_watering = false
		)

func safe_sell() -> void:
	var plant: Plant = plants[plant_index]
	
	if plant != null:
		add_child(confirmation_dialog.instantiate())
		pauseable.process_mode = Node.PROCESS_MODE_DISABLED

func sell_plant() -> void:
	if is_watering:
		return
	
	var plant: Plant = plants[plant_index]
	
	if plant != null:
		add_coins((plant.phase + 1) * (plant.species + 1) * 50)
		plants[plant_index] = null
		
		var plant_pot: TextureButton = get_node('Pauseable/FlowerPot' + str(plant_index))
		var cactus: Node2D =  plant_pot.get_node('Cactus')
		
		plant_pot.unenchanted()
		if cactus != null:
			cactus.queue_free()
		update_phase()
		update_name()

func _on_shop_button_pressed() -> void:
	var shopoo_panel: Panel = shopoo_panel_packed_scene.instantiate()
	
	pauseable.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(shopoo_panel)

func pause() -> void:
	pauseable.process_mode = Node.PROCESS_MODE_DISABLED

func resume() -> void:
	pauseable.process_mode = Node.PROCESS_MODE_ALWAYS
