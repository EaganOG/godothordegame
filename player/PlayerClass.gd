# PlayerClass.gd
extends Resource
class_name PlayerClass

@export var player_class_name: String
@export var description: String
@export var icon_path: String

# Base stats
@export var base_health: int = 100
@export var base_stamina: int = 100
@export var base_speed: int = 600
@export var base_damage: int = 25

# Stat multipliers (1.0 = normal, 1.5 = 50% bonus, etc.)
@export var health_multiplier: float = 1.0
@export var stamina_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0
@export var attack_speed_multiplier: float = 1.0

# Special abilities
@export var has_double_shot: bool = false
@export var has_piercing_arrows: bool = false
@export var has_regeneration: bool = false
@export var has_stamina_regen: bool = true
@export var has_dash: bool = false

# Active abilities (bound to keys)
var ability_1: Ability = null
var ability_2: Ability = null
var ability_3: Ability = null

# Create preset classes
static func create_short_horn_lizard() -> PlayerClass:
	var short_horn_lizard = PlayerClass.new()
	short_horn_lizard.player_class_name = "Short Horn Lizard"
	short_horn_lizard.description = "Master of ranged combat with enhanced bow skills"
	short_horn_lizard.icon_path = "res://icons/archer.png"
	short_horn_lizard.damage_multiplier = 1.3
	short_horn_lizard.attack_speed_multiplier = 1.5
	short_horn_lizard.has_double_shot = true
	short_horn_lizard.speed_multiplier = 1.2
	short_horn_lizard.has_stamina_regen = true
	
	# Abilities
	short_horn_lizard.ability_1 = Ability.create_blood_squirt_ability()
	short_horn_lizard.ability_2 = Ability.create_dash_ability()
	
	return short_horn_lizard

static func create_cane_toad() -> PlayerClass:
	var cane_toad = PlayerClass.new()
	cane_toad.player_class_name = "Cane Toad"
	cane_toad.description = "Tough melee fighter with high health and defense"
	cane_toad.icon_path = "res://icons/warrior.png"
	cane_toad.health_multiplier = 1.8
	cane_toad.speed_multiplier = 0.8
	cane_toad.damage_multiplier = 1.1
	cane_toad.has_dash = true
	cane_toad.has_stamina_regen = true
	
	# Abilities
	cane_toad.ability_1 = Ability.create_charge_ability()
	cane_toad.ability_2 = Ability.create_mud_wallow_ability()
	
	return cane_toad

static func create_pig() -> PlayerClass:
	var pig = PlayerClass.new()
	pig.player_class_name = "Pig"
	pig.description = "Magical archer with piercing projectiles and regeneration"
	pig.icon_path = "res://icons/mage.png"
	pig.stamina_multiplier = 1.5
	pig.has_piercing_arrows = true
	pig.has_regeneration = true
	pig.has_stamina_regen = true
	pig.damage_multiplier = 1.2
	pig.health_multiplier = 0.8
	
	# Abilities
	pig.ability_1 = Ability.create_mud_wallow_ability()
	pig.ability_2 = Ability.create_charge_ability()
	
	return pig

static func create_slug() -> PlayerClass:
	var slug = PlayerClass.new()
	slug.player_class_name = "Slug"
	slug.description = "Slow, fat and dangerous"
	slug.icon_path = "res://icons/scout.png"
	slug.speed_multiplier = 0.5  # Actually slow for slug
	slug.attack_speed_multiplier = 0.7  # Slow attacks
	slug.health_multiplier = 2.0  # Very tanky
	slug.has_dash = false  # Slugs don't dash!
	slug.has_stamina_regen = true
	
	# Abilities
	slug.ability_1 = Ability.create_slime_bomb_ability()
	slug.ability_2 = Ability.create_mud_wallow_ability()
	slug.ability_3 = Ability.create_double_jump_ability()  # Slug gets 3 abilities!
	
	return slug

static func get_all_classes() -> Array[PlayerClass]:
	return [
		create_short_horn_lizard(),
		create_cane_toad(),
		create_pig(),
		create_slug()
	]
