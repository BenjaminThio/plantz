class_name Plant extends Node

const MAX_PHASE: int = 10

enum SPECIES {
	CACTUS
}

var species: SPECIES = SPECIES.CACTUS
var phase: int = 0
var plant_name: String = ''
var is_fertilized: bool = false

func _init(default_species: SPECIES, default_plant_name: String) -> void:
	self.species = default_species
	self.plant_name = default_plant_name

func upgrade_phase(amount: int = 1) -> void:
	if is_fertilized and phase + amount <= MAX_PHASE:
		phase += amount
		is_fertilized = false
