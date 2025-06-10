# PerkManager.gd
extends Node

var player_perks: Array[Perk] = []
var available_perks: Array[Perk] = []

signal perk_selected(perk: Perk)

func _ready():
	available_perks = Perk.get_all_perks()
	print("PerkManager loaded with ", available_perks.size(), " perks")

func get_random_perk_choices(count: int = 3) -> Array[Perk]:
	var choices: Array[Perk] = []
	var available_for_selection: Array[Perk] = []
	
	for perk in available_perks:
		if not perk:
			continue
		
		var existing_perk = find_existing_perk(perk.name)
		if existing_perk == null or existing_perk.current_stacks < existing_perk.max_stacks:
			available_for_selection.append(perk)
	
	count = min(count, available_for_selection.size())
	
	for i in range(count):
		if available_for_selection.is_empty():
			break
			
		var selected_perk = select_weighted_random_perk(available_for_selection)
		if selected_perk:
			choices.append(selected_perk)
			available_for_selection.erase(selected_perk)
	
	return choices

func select_weighted_random_perk(perk_list: Array[Perk]) -> Perk:
	if perk_list.is_empty():
		return null
	
	var weights: Array[float] = []
	var total_weight = 0.0
	
	for perk in perk_list:
		if not perk:
			continue
		
		var weight = get_rarity_weight(perk.rarity)
		weights.append(weight)
		total_weight += weight
	
	if total_weight <= 0:
		return perk_list[0] if perk_list.size() > 0 else null
	
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for i in range(perk_list.size()):
		current_weight += weights[i]
		if random_value <= current_weight:
			return perk_list[i]
	
	return perk_list[-1] if perk_list.size() > 0 else null

func get_rarity_weight(rarity: Perk.PerkRarity) -> float:
	match rarity:
		Perk.PerkRarity.COMMON:
			return 50.0
		Perk.PerkRarity.UNCOMMON:
			return 25.0
		Perk.PerkRarity.RARE:
			return 15.0
		Perk.PerkRarity.EPIC:
			return 10.0
		_:
			return 25.0

func apply_perk(perk: Perk, player) -> void:
	if not perk or not player:
		print("Warning: Invalid perk or player in apply_perk")
		return
	
	var existing_perk = find_existing_perk(perk.name)
	
	if existing_perk:
		if existing_perk.current_stacks < existing_perk.max_stacks:
			existing_perk.apply_perk(player)
		else:
			print("Perk ", perk.name, " is already at max stacks")
	else:
		var new_perk = create_perk_instance(perk)
		if new_perk:
			player_perks.append(new_perk)
			new_perk.apply_perk(player)

func create_perk_instance(template_perk: Perk) -> Perk:
	if not template_perk:
		return null
	
	match template_perk.name:
		"Vitality":
			return Perk.HealthBoostPerk.new()
		"Natural Healing":
			return Perk.RegenerationPerk.new()
		"Sharp Arrows":
			return Perk.DamageBoostPerk.new()
		"Critical Eye":
			return Perk.CriticalStrikePerk.new()
		"Swift Feet":
			return Perk.SpeedBoostPerk.new()
		"Rapid Fire":
			return Perk.AttackSpeedPerk.new()
		"Vampiric Arrows":
			return Perk.VampirePerk.new()
		"Explosive Tips":
			return Perk.ExplosiveArrowsPerk.new()
		"Lucky Dodge":
			return Perk.LuckyDodgePerk.new()
		"Long Reach":
			return Perk.MeleeRangePerk.new()
		"Heavy Blows":
			return Perk.KnockbackPerk.new()
		"Vampiric Strike":
			return Perk.LifeStealPerk.new()
		_:
			print("Unknown perk type: ", template_perk.name)
			return template_perk

func find_existing_perk(perk_name: String) -> Perk:
	for perk in player_perks:
		if perk and perk.name == perk_name:
			return perk
	return null

func process_perk_ticks(player, delta: float) -> void:
	if not player:
		return
	
	for perk in player_perks:
		if perk:
			perk.on_tick(player, delta)

func trigger_enemy_killed(player, enemy) -> void:
	if not player:
		return
	
	for perk in player_perks:
		if perk:
			perk.on_enemy_killed(player, enemy)

func trigger_damage_taken(player, damage: int) -> bool:
	if not player:
		return false
	
	for perk in player_perks:
		if perk and perk.on_damage_taken(player, damage):
			return true
	return false

func trigger_attack(player) -> void:
	if not player:
		return
	
	for perk in player_perks:
		if perk:
			perk.on_attack(player)

func get_perk_summary() -> String:
	var summary = "Active Perks:\n"
	for perk in player_perks:
		if perk:
			summary += "• " + perk.name
			if perk.max_stacks > 1:
				summary += " (" + str(perk.current_stacks) + "/" + str(perk.max_stacks) + ")"
			summary += "\n"
	return summary

func reset_perks() -> void:
	player_perks.clear()
	print("All perks reset")

func player_has_perk(perk_name: String) -> bool:
	return find_existing_perk(perk_name) != null

func get_perk_stacks(perk_name: String) -> int:
	var perk = find_existing_perk(perk_name)
	return perk.current_stacks if perk else 0

# Debug functions
func debug_list_perks():
	print("Available perks:")
	for perk in available_perks:
		if perk:
			print("- ", perk.name, " (", Perk.PerkRarity.keys()[perk.rarity], ")")

func debug_add_random_perk(player):
	var choices = get_random_perk_choices(1)
	if choices.size() > 0:
		apply_perk(choices[0], player)
		print("Added random perk: ", choices[0].name)
	else:
		print("No perks available to add")

func debug_print_active_perks():
	print(get_perk_summary())
