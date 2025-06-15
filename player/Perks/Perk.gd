# Perk.gd
extends Resource
class_name Perk

enum Rarity {
	COMMON,
	RARE,
	LEGENDARY,
	EPIC
}

enum PerkType {
	HEALTH,
	STAMINA,
	DAMAGE,
	ATTACK_SPEED,
	MOVEMENT_SPEED,
	HEALTH_REGEN,
	STAMINA_REGEN,
	ABILITY_COOLDOWN,
	PIERCE_CHANCE,
	DOUBLE_SHOT_CHANCE
}

@export var perk_name: String
@export var description: String
@export var rarity: Rarity
@export var perk_type: PerkType
@export var multiplier: float
@export var icon_path: String
@export var max_stacks: int = 3

# Get rarity color for UI
func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON:
			return Color.WHITE
		Rarity.RARE:
			return Color.CYAN
		Rarity.LEGENDARY:
			return Color.MAGENTA
		Rarity.EPIC:
			return Color.GOLD
		_:
			return Color.WHITE

# Get rarity name as string
func get_rarity_name() -> String:
	match rarity:
		Rarity.COMMON:
			return "Common"
		Rarity.RARE:
			return "Rare"
		Rarity.LEGENDARY:
			return "Legendary"
		Rarity.EPIC:
			return "Epic"
		_:
			return "Unknown"

# Static factory methods for creating perks
static func create_health_perk(rarity: Rarity) -> Perk:
	var perk = Perk.new()
	perk.perk_type = PerkType.HEALTH
	perk.rarity = rarity
	
	match rarity:
		Rarity.COMMON:
			perk.perk_name = "Vitality"
			perk.multiplier = 1.15
			perk.description = "+15% Maximum Health"
		Rarity.RARE:
			perk.perk_name = "Robust Constitution"
			perk.multiplier = 1.25
			perk.description = "+25% Maximum Health"
		Rarity.LEGENDARY:
			perk.perk_name = "Immortal Flesh"
			perk.multiplier = 1.40
			perk.description = "+40% Maximum Health"
		Rarity.EPIC:
			perk.perk_name = "Divine Endurance"
			perk.multiplier = 1.60
			perk.description = "+60% Maximum Health"
	
	return perk

static func create_stamina_perk(rarity: Rarity) -> Perk:
	var perk = Perk.new()
	perk.perk_type = PerkType.STAMINA
	perk.rarity = rarity
	
	match rarity:
		Rarity.COMMON:
			perk.perk_name = "Endurance"
			perk.multiplier = 1.15
			perk.description = "+15% Maximum Stamina"
		Rarity.RARE:
			perk.perk_name = "Athletic Prowess"
			perk.multiplier = 1.25
			perk.description = "+25% Maximum Stamina"
		Rarity.LEGENDARY:
			perk.perk_name = "Boundless Energy"
			perk.multiplier = 1.40
			perk.description = "+40% Maximum Stamina"
		Rarity.EPIC:
			perk.perk_name = "Infinite Reserves"
			perk.multiplier = 1.60
			perk.description = "+60% Maximum Stamina"
	
	return perk

static func create_damage_perk(rarity: Rarity) -> Perk:
	var perk = Perk.new()
	perk.perk_type = PerkType.DAMAGE
	perk.rarity = rarity
	
	match rarity:
		Rarity.COMMON:
			perk.perk_name = "Sharp Edge"
			perk.multiplier = 1.12
			perk.description = "+12% Damage"
		Rarity.RARE:
			perk.perk_name = "Lethal Force"
			perk.multiplier = 1.20
			perk.description = "+20% Damage"
		Rarity.LEGENDARY:
			perk.perk_name = "Devastating Strike"
			perk.multiplier = 1.35
			perk.description = "+35% Damage"
		Rarity.EPIC:
			perk.perk_name = "Annihilation"
			perk.multiplier = 1.50
			perk.description = "+50% Damage"
	
	return perk

static func create_attack_speed_perk(rarity: Rarity) -> Perk:
	var perk = Perk.new()
	perk.perk_type = PerkType.ATTACK_SPEED
	perk.rarity = rarity
	
	match rarity:
		Rarity.COMMON:
			perk.perk_name = "Quick Draw"
			perk.multiplier = 1.15
			perk.description = "+15% Attack Speed"
		Rarity.RARE:
			perk.perk_name = "Rapid Fire"
			perk.multiplier = 1.25
			perk.description = "+25% Attack Speed"
		Rarity.LEGENDARY:
			perk.perk_name = "Lightning Reflexes"
			perk.multiplier = 1.40
			perk.description = "+40% Attack Speed"
		Rarity.EPIC:
			perk.perk_name = "Time Dilation"
			perk.multiplier = 1.60
			perk.description = "+60% Attack Speed"
	
	return perk

static func create_movement_speed_perk(rarity: Rarity) -> Perk:
	var perk = Perk.new()
	perk.perk_type = PerkType.MOVEMENT_SPEED
	perk.rarity = rarity
	
	match rarity:
		Rarity.COMMON:
			perk.perk_name = "Swift Feet"
			perk.multiplier = 1.10
			perk.description = "+10% Movement Speed"
		Rarity.RARE:
			perk.perk_name = "Fleet Footed"
			perk.multiplier = 1.18
			perk.description = "+18% Movement Speed"
		Rarity.LEGENDARY:
			perk.perk_name = "Wind Walker"
			perk.multiplier = 1.30
			perk.description = "+30% Movement Speed"
		Rarity.EPIC:
			perk.perk_name = "Sonic Stride"
			perk.multiplier = 1.45
			perk.description = "+45% Movement Speed"
	
	return perk

static func create_ability_cooldown_perk(rarity: Rarity) -> Perk:
	var perk = Perk.new()
	perk.perk_type = PerkType.ABILITY_COOLDOWN
	perk.rarity = rarity
	
	match rarity:
		Rarity.COMMON:
			perk.perk_name = "Quick Recovery"
			perk.multiplier = 0.90  # Reduces cooldown by 10%
			perk.description = "-10% Ability Cooldowns"
		Rarity.RARE:
			perk.perk_name = "Efficient Casting"
			perk.multiplier = 0.80  # Reduces cooldown by 20%
			perk.description = "-20% Ability Cooldowns"
		Rarity.LEGENDARY:
			perk.perk_name = "Arcane Mastery"
			perk.multiplier = 0.65  # Reduces cooldown by 35%
			perk.description = "-35% Ability Cooldowns"
		Rarity.EPIC:
			perk.perk_name = "Temporal Control"
			perk.multiplier = 0.50  # Reduces cooldown by 50%
			perk.description = "-50% Ability Cooldowns"
	
	return perk

static func create_health_regen_perk(rarity: Rarity) -> Perk:
	var perk = Perk.new()
	perk.perk_type = PerkType.HEALTH_REGEN
	perk.rarity = rarity
	
	match rarity:
		Rarity.COMMON:
			perk.perk_name = "Natural Healing"
			perk.multiplier = 1.25
			perk.description = "+25% Health Regeneration Rate"
		Rarity.RARE:
			perk.perk_name = "Accelerated Recovery"
			perk.multiplier = 1.50
			perk.description = "+50% Health Regeneration Rate"
		Rarity.LEGENDARY:
			perk.perk_name = "Rapid Regeneration"
			perk.multiplier = 2.00
			perk.description = "+100% Health Regeneration Rate"
		Rarity.EPIC:
			perk.perk_name = "Phoenix Blood"
			perk.multiplier = 3.00
			perk.description = "+200% Health Regeneration Rate"
	
	return perk

static func create_stamina_regen_perk(rarity: Rarity) -> Perk:
	var perk = Perk.new()
	perk.perk_type = PerkType.STAMINA_REGEN
	perk.rarity = rarity
	
	match rarity:
		Rarity.COMMON:
			perk.perk_name = "Second Wind"
			perk.multiplier = 1.25
			perk.description = "+25% Stamina Regeneration Rate"
		Rarity.RARE:
			perk.perk_name = "Endless Vigor"
			perk.multiplier = 1.50
			perk.description = "+50% Stamina Regeneration Rate"
		Rarity.LEGENDARY:
			perk.perk_name = "Boundless Spirit"
			perk.multiplier = 2.00
			perk.description = "+100% Stamina Regeneration Rate"
		Rarity.EPIC:
			perk.perk_name = "Eternal Energy"
			perk.multiplier = 3.00
			perk.description = "+200% Stamina Regeneration Rate"
	
	return perk

# Get all available perk types
static func get_all_perk_types() -> Array[PerkType]:
	return [
		PerkType.HEALTH,
		PerkType.STAMINA,
		PerkType.DAMAGE,
		PerkType.ATTACK_SPEED,
		PerkType.MOVEMENT_SPEED,
		PerkType.HEALTH_REGEN,
		PerkType.STAMINA_REGEN,
		PerkType.ABILITY_COOLDOWN
	]

# Create a perk of specific type and rarity
static func create_perk(perk_type: PerkType, rarity: Rarity) -> Perk:
	match perk_type:
		PerkType.HEALTH:
			return create_health_perk(rarity)
		PerkType.STAMINA:
			return create_stamina_perk(rarity)
		PerkType.DAMAGE:
			return create_damage_perk(rarity)
		PerkType.ATTACK_SPEED:
			return create_attack_speed_perk(rarity)
		PerkType.MOVEMENT_SPEED:
			return create_movement_speed_perk(rarity)
		PerkType.HEALTH_REGEN:
			return create_health_regen_perk(rarity)
		PerkType.STAMINA_REGEN:
			return create_stamina_regen_perk(rarity)
		PerkType.ABILITY_COOLDOWN:
			return create_ability_cooldown_perk(rarity)
		_:
			return create_health_perk(rarity)  # Fallback
