# PlayerClass.gd
extends Resource
class_name PlayerClass

@export var player_class_name: String  # FIXED: was game_class_name
@export var description: String
@export var icon_path: String

# Combat type
enum CombatType {
	RANGED,
	MELEE,
	HYBRID
}

@export var combat_type: CombatType = CombatType.RANGED

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

# Melee specific stats
@export var melee_range: float = 100.0
@export var melee_knockback: float = 200.0
@export var melee_aoe_radius: float = 0.0

# Ranged specific stats
@export var projectile_speed: float = 800.0
@export var projectile_count: int = 1

# Special abilities
@export var has_double_shot: bool = false
@export var has_piercing_arrows: bool = false
@export var has_regeneration: bool = false
@export var has_dash: bool = false
@export var has_charge_attack: bool = false
@export var has_whirlwind: bool = false
@export var has_life_steal: bool = false

# RANGED CLASSES
static func create_archer() -> PlayerClass:
	var archer = PlayerClass.new()
	archer.player_class_name = "Archer"  # FIXED
	archer.description = "Master of ranged combat with enhanced bow skills"
	archer.icon_path = "res://icons/archer.png"
	archer.combat_type = CombatType.RANGED
	archer.damage_multiplier = 1.3
	archer.attack_speed_multiplier = 1.5
	archer.has_double_shot = true
	archer.speed_multiplier = 1.2
	archer.projectile_speed = 1000.0
	return archer

static func create_mage() -> PlayerClass:
	var mage = PlayerClass.new()
	mage.player_class_name = "Mage"  # FIXED
	mage.description = "Magical archer with piercing projectiles and regeneration"
	mage.icon_path = "res://icons/mage.png"
	mage.combat_type = CombatType.RANGED
	mage.stamina_multiplier = 1.5
	mage.has_piercing_arrows = true
	mage.has_regeneration = true
	mage.damage_multiplier = 1.2
	mage.health_multiplier = 0.8
	mage.projectile_speed = 600.0
	return mage

static func create_scout() -> PlayerClass:
	var scout = PlayerClass.new()
	scout.player_class_name = "Scout"  # FIXED
	scout.description = "Fast ranged fighter with rapid movement and attacks"
	scout.icon_path = "res://icons/scout.png"
	scout.combat_type = CombatType.RANGED
	scout.speed_multiplier = 1.6
	scout.attack_speed_multiplier = 1.8
	scout.health_multiplier = 0.9
	scout.has_dash = true
	scout.projectile_speed = 1200.0
	return scout

# MELEE CLASSES
static func create_warrior() -> PlayerClass:
	var warrior = PlayerClass.new()
	warrior.player_class_name = "Warrior"  # FIXED
	warrior.description = "Tough melee fighter with high health and powerful strikes"
	warrior.icon_path = "res://icons/warrior.png"
	warrior.combat_type = CombatType.MELEE
	warrior.health_multiplier = 1.8
	warrior.speed_multiplier = 0.9
	warrior.damage_multiplier = 1.4
	warrior.has_dash = true
	warrior.has_charge_attack = true
	warrior.melee_range = 120.0
	warrior.melee_knockback = 300.0
	return warrior

static func create_berserker() -> PlayerClass:
	var berserker = PlayerClass.new()
	berserker.player_class_name = "Berserker"  # FIXED
	berserker.description = "Frenzied melee fighter with life steal and whirlwind attacks"
	berserker.icon_path = "res://icons/berserker.png"
	berserker.combat_type = CombatType.MELEE
	berserker.health_multiplier = 1.3
	berserker.damage_multiplier = 1.5
	berserker.attack_speed_multiplier = 1.6
	berserker.speed_multiplier = 1.1
	berserker.has_life_steal = true
	berserker.has_whirlwind = true
	berserker.melee_range = 100.0
	berserker.melee_knockback = 250.0
	berserker.melee_aoe_radius = 80.0
	return berserker

static func create_paladin() -> PlayerClass:
	var paladin = PlayerClass.new()
	paladin.player_class_name = "Paladin"  # FIXED
	paladin.description = "Holy warrior with regeneration and area attacks"
	paladin.icon_path = "res://icons/paladin.png"
	paladin.combat_type = CombatType.MELEE
	paladin.health_multiplier = 2.0
	paladin.stamina_multiplier = 1.3
	paladin.damage_multiplier = 1.2
	paladin.speed_multiplier = 0.8
	paladin.has_regeneration = true
	paladin.has_dash = true
	paladin.melee_range = 110.0
	paladin.melee_knockback = 200.0
	paladin.melee_aoe_radius = 60.0
	return paladin

static func create_assassin() -> PlayerClass:
	var assassin = PlayerClass.new()
	assassin.player_class_name = "Assassin"  # FIXED
	assassin.description = "Fast melee fighter with high damage and mobility"
	assassin.icon_path = "res://icons/assassin.png"
	assassin.combat_type = CombatType.MELEE
	assassin.health_multiplier = 0.7
	assassin.damage_multiplier = 1.8
	assassin.speed_multiplier = 1.7
	assassin.attack_speed_multiplier = 2.0
	assassin.has_dash = true
	assassin.melee_range = 90.0
	assassin.melee_knockback = 150.0
	return assassin

# HYBRID CLASS
static func create_spellsword() -> PlayerClass:
	var spellsword = PlayerClass.new()
	spellsword.player_class_name = "Spellsword"  # FIXED
	spellsword.description = "Versatile fighter capable of both melee and ranged combat"
	spellsword.icon_path = "res://icons/spellsword.png"
	spellsword.combat_type = CombatType.HYBRID
	spellsword.health_multiplier = 1.2
	spellsword.stamina_multiplier = 1.4
	spellsword.damage_multiplier = 1.1
	spellsword.speed_multiplier = 1.0
	spellsword.has_dash = true
	spellsword.has_piercing_arrows = true
	spellsword.melee_range = 100.0
	spellsword.melee_knockback = 200.0
	spellsword.projectile_speed = 700.0
	return spellsword

static func create_slug() -> PlayerClass:
	var slug = PlayerClass.new()
	slug.player_class_name = "Slug"  # FIXED
	slug.description = "Slow Tank - Melee powerhouse with massive health"
	slug.icon_path = "res://icons/slug.png"
	slug.combat_type = CombatType.MELEE
	slug.speed_multiplier = 0.4
	slug.attack_speed_multiplier = 0.5
	slug.health_multiplier = 4.0
	slug.damage_multiplier = 1.6
	slug.has_regeneration = true
	slug.melee_range = 80.0
	slug.melee_knockback = 400.0
	slug.melee_aoe_radius = 100.0
	return slug

static func get_all_classes() -> Array[PlayerClass]:
	return [
		create_archer(),
		#create_mage(),
		create_scout(),
		create_warrior(),
		#create_berserker(),
		#create_paladin(),
		create_assassin(),
		create_slug(),
		#create_spellsword()
	]

static func get_ranged_classes() -> Array[PlayerClass]:
	return [
		create_archer(),
		create_mage(),
		create_scout()
	]

static func get_melee_classes() -> Array[PlayerClass]:
	return [
		create_warrior(),
		create_berserker(),
		create_paladin(),
		create_assassin(),
		create_slug()
	]

static func get_hybrid_classes() -> Array[PlayerClass]:
	return [
		create_spellsword()
	]
