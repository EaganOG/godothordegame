# perk.gd
class_name Perk
extends Resource

@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var rarity: PerkRarity = PerkRarity.COMMON
@export var max_stacks: int = 1
var current_stacks: int = 0

enum PerkRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC
}

func apply_perk(player) -> void:
	if not player:
		print("Warning: apply_perk called with null player")
		return
	
	current_stacks += 1
	print("Applied perk: ", name, " (Stack: ", current_stacks, ")")

func on_tick(player, delta: float) -> void:
	if not player:
		return

func on_enemy_killed(player, enemy) -> void:
	if not player:
		return

func on_damage_taken(player, damage: int) -> bool:
	if not player:
		return false
	return false

func on_attack(player) -> void:
	if not player:
		return

static func get_all_perks() -> Array[Perk]:
	var perks: Array[Perk] = []
	
	# Health perks
	perks.append(HealthBoostPerk.new())
	perks.append(RegenerationPerk.new())
	
	# Damage perks
	perks.append(DamageBoostPerk.new())
	perks.append(CriticalStrikePerk.new())
	
	# Speed perks
	perks.append(SpeedBoostPerk.new())
	perks.append(AttackSpeedPerk.new())
	
	# Special perks
	perks.append(VampirePerk.new())
	perks.append(ExplosiveArrowsPerk.new())
	perks.append(LuckyDodgePerk.new())
	
	# Melee perks
	perks.append(MeleeRangePerk.new())
	perks.append(KnockbackPerk.new())
	perks.append(LifeStealPerk.new())
	
	return perks

# HEALTH PERKS
class HealthBoostPerk extends Perk:
	func _init():
		name = "Vitality"
		description = "Increases maximum health by 20"
		rarity = PerkRarity.COMMON
		max_stacks = 5

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if "max_health" in player and "health" in player:
			player.max_health += 20
			player.health += 20

class RegenerationPerk extends Perk:
	func _init():
		name = "Natural Healing"
		description = "Regenerate 1 additional HP per second"
		rarity = PerkRarity.UNCOMMON
		max_stacks = 3

	func apply_perk(player) -> void:
		super.apply_perk(player)

	func on_tick(player, delta: float) -> void:
		if not player or current_stacks <= 0:
			return
		
		if not ("regen_timer" in player and "regen_rate" in player):
			return
		
		if not ("health" in player and "max_health" in player):
			return
		
		player.regen_timer += delta * current_stacks
		
		if player.regen_timer >= player.regen_rate and player.health < player.max_health:
			var heal_amount = current_stacks
			player.health = min(player.health + heal_amount, player.max_health)
			player.regen_timer = 0.0

# DAMAGE PERKS
class DamageBoostPerk extends Perk:
	func _init():
		name = "Sharp Arrows"
		description = "Increases damage by 15%"
		rarity = PerkRarity.COMMON
		max_stacks = 4

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if "damage" in player:
			player.damage = int(player.damage * 1.15)

class CriticalStrikePerk extends Perk:
	func _init():
		name = "Critical Eye"
		description = "10% chance to deal double damage"
		rarity = PerkRarity.RARE
		max_stacks = 3

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if not player.has_meta("crit_chance"):
			player.set_meta("crit_chance", 0.0)
		player.set_meta("crit_chance", player.get_meta("crit_chance") + 0.1)

# SPEED PERKS
class SpeedBoostPerk extends Perk:
	func _init():
		name = "Swift Feet"
		description = "Increases movement speed by 20%"
		rarity = PerkRarity.COMMON
		max_stacks = 3

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if "SPEED" in player:
			player.SPEED = int(player.SPEED * 1.2)

class AttackSpeedPerk extends Perk:
	func _init():
		name = "Rapid Fire"
		description = "Increases attack speed by 25%"
		rarity = PerkRarity.UNCOMMON
		max_stacks = 4

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if "shoot_cooldown" in player:
			player.shoot_cooldown = player.shoot_cooldown * 0.75
		if "melee_cooldown" in player:
			player.melee_cooldown = player.melee_cooldown * 0.75

# SPECIAL PERKS
class VampirePerk extends Perk:
	func _init():
		name = "Vampiric Arrows"
		description = "Heal 2 HP when killing an enemy"
		rarity = PerkRarity.RARE
		max_stacks = 3

	func apply_perk(player) -> void:
		super.apply_perk(player)

	func on_enemy_killed(player, enemy) -> void:
		if not player or current_stacks <= 0:
			return
		
		if "health" in player and "max_health" in player:
			var heal_amount = 2 * current_stacks
			player.health = min(player.health + heal_amount, player.max_health)

class ExplosiveArrowsPerk extends Perk:
	func _init():
		name = "Explosive Tips"
		description = "Arrows have 15% chance to explode on impact"
		rarity = PerkRarity.EPIC
		max_stacks = 2

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if not player.has_meta("explosive_chance"):
			player.set_meta("explosive_chance", 0.0)
		player.set_meta("explosive_chance", player.get_meta("explosive_chance") + 0.15)

class LuckyDodgePerk extends Perk:
	func _init():
		name = "Lucky Dodge"
		description = "5% chance to completely avoid damage"
		rarity = PerkRarity.RARE
		max_stacks = 4

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if not player.has_meta("dodge_chance"):
			player.set_meta("dodge_chance", 0.0)
		player.set_meta("dodge_chance", player.get_meta("dodge_chance") + 0.05)

	func on_damage_taken(player, damage: int) -> bool:
		if not player or current_stacks <= 0:
			return false
		
		var dodge_chance = player.get_meta("dodge_chance", 0.0)
		if randf() < dodge_chance:
			print("Lucky dodge!")
			return true
		return false

# MELEE PERKS
class MeleeRangePerk extends Perk:
	func _init():
		name = "Long Reach"
		description = "Increases melee attack range by 30%"
		rarity = PerkRarity.COMMON
		max_stacks = 3

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if "current_melee_weapon" in player and player.current_melee_weapon:
			player.current_melee_weapon.attack_range *= 1.3

class KnockbackPerk extends Perk:
	func _init():
		name = "Heavy Blows"
		description = "Increases knockback force by 50%"
		rarity = PerkRarity.UNCOMMON
		max_stacks = 3

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if "current_melee_weapon" in player and player.current_melee_weapon:
			player.current_melee_weapon.knockback_force *= 1.5

class LifeStealPerk extends Perk:
	func _init():
		name = "Vampiric Strike"
		description = "Heal 10% of melee damage dealt"
		rarity = PerkRarity.RARE
		max_stacks = 2

	func apply_perk(player) -> void:
		super.apply_perk(player)
		if "current_melee_weapon" in player and player.current_melee_weapon:
			player.current_melee_weapon.life_steal_percent += 0.1
