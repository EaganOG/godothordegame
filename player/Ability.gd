# Ability.gd
extends Resource
class_name Ability

@export var ability_name: String
@export var description: String
@export var icon_path: String
@export var cooldown: float = 2.0
@export var stamina_cost: int = 20

# Ability effects - these get overridden by specific abilities
func activate(player: CharacterBody2D) -> bool:
	# Base implementation - override in specific abilities
	print("Base ability activated")
	return true

func can_use(player) -> bool:
	return player.stamina >= stamina_cost

# Static factory methods for creating specific abilities
static func create_dash_ability() -> Ability:
	var ability = Ability.new()
	ability.ability_name = "Dash"
	ability.description = "Quick burst of speed with invulnerability"
	ability.cooldown = 3.0
	ability.stamina_cost = 25
	return ability

static func create_slime_bomb_ability() -> Ability:
	var ability = Ability.new()
	ability.ability_name = "Slime Bomb"
	ability.description = "Throws a slowing slime projectile"
	ability.cooldown = 4.0
	ability.stamina_cost = 30
	return ability

static func create_blood_squirt_ability() -> Ability:
	var ability = Ability.new()
	ability.ability_name = "Blood Squirt"
	ability.description = "Defensive blood spray that damages and knockbacks enemies"
	ability.cooldown = 5.0
	ability.stamina_cost = 40
	return ability

static func create_mud_wallow_ability() -> Ability:
	var ability = Ability.new()
	ability.ability_name = "Mud Wallow"
	ability.description = "Temporary health regeneration and damage reduction"
	ability.cooldown = 8.0
	ability.stamina_cost = 35
	return ability

static func create_charge_ability() -> Ability:
	var ability = Ability.new()
	ability.ability_name = "Charge"
	ability.description = "Powerful forward charge that damages enemies"
	ability.cooldown = 6.0
	ability.stamina_cost = 45
	return ability

static func create_double_jump_ability() -> Ability:
	var ability = Ability.new()
	ability.ability_name = "Double Jump"
	ability.description = "Quick aerial maneuver"
	ability.cooldown = 1.0
	ability.stamina_cost = 15
	return ability
