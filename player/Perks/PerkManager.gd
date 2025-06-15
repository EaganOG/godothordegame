# PerkManager.gd
extends Node
class_name PerkManager

# Dictionary to store perk stacks: {perk_type: {rarity: stack_count}}
var perk_stacks: Dictionary = {}

# Cached multipliers for performance
var cached_multipliers: Dictionary = {}
var cache_dirty: bool = true

signal perks_updated

func _ready():
	# Initialize empty perk tracking
	initialize_perk_stacks()

func initialize_perk_stacks():
	perk_stacks.clear()
	for perk_type in Perk.get_all_perk_types():
		perk_stacks[perk_type] = {}
		for rarity in [Perk.Rarity.COMMON, Perk.Rarity.RARE, Perk.Rarity.LEGENDARY, Perk.Rarity.EPIC]:
			perk_stacks[perk_type][rarity] = 0
	print("Perk stacks initialized: ", perk_stacks)

# Add a perk to the player's collection
func add_perk(perk: Perk) -> bool:
	if not perk:
		print("ERROR: Perk is null")
		return false
	
	# Ensure perk stacks are initialized
	if not perk_stacks.has(perk.perk_type):
		print("ERROR: Perk type not found in stacks: ", perk.perk_type)
		initialize_perk_stacks()
	
	if not perk_stacks[perk.perk_type].has(perk.rarity):
		print("ERROR: Perk rarity not found: ", perk.rarity)
		perk_stacks[perk.perk_type][perk.rarity] = 0
	
	# Check if we can add more of this perk
	var current_stacks = perk_stacks[perk.perk_type][perk.rarity]
	if current_stacks >= perk.max_stacks:
		print("Cannot add perk - already at max stacks: ", current_stacks, "/", perk.max_stacks)
		return false
	
	# Add the perk
	perk_stacks[perk.perk_type][perk.rarity] += 1
	cache_dirty = true
	perks_updated.emit()
	
	print("Added perk: ", perk.perk_name, " (", current_stacks + 1, "/", perk.max_stacks, ")")
	return true

# Get the current stack count for a specific perk
func get_perk_stacks(perk_type: Perk.PerkType, rarity: Perk.Rarity) -> int:
	if not perk_stacks.has(perk_type):
		print("WARNING: Perk type not found: ", perk_type)
		return 0
	if not perk_stacks[perk_type].has(rarity):
		print("WARNING: Perk rarity not found: ", rarity)
		return 0
	return perk_stacks[perk_type][rarity]

# Check if a perk can be added (not at max stacks)
func can_add_perk(perk: Perk) -> bool:
	if not perk:
		return false
	var current_stacks = get_perk_stacks(perk.perk_type, perk.rarity)
	return current_stacks < perk.max_stacks

# Get total multiplier for a specific stat type
func get_stat_multiplier(perk_type: Perk.PerkType) -> float:
	if cache_dirty:
		_update_cached_multipliers()
	
	return cached_multipliers.get(perk_type, 1.0)

# Update cached multipliers for performance
func _update_cached_multipliers():
	cached_multipliers.clear()
	
	for perk_type in Perk.get_all_perk_types():
		var total_multiplier = 1.0
		
		# Ensure perk_stacks has this perk_type
		if not perk_stacks.has(perk_type):
			cached_multipliers[perk_type] = 1.0
			continue
		
		# Calculate multiplier for each rarity
		for rarity in [Perk.Rarity.COMMON, Perk.Rarity.RARE, Perk.Rarity.LEGENDARY, Perk.Rarity.EPIC]:
			if not perk_stacks[perk_type].has(rarity):
				continue
				
			var stack_count = perk_stacks[perk_type][rarity]
			if stack_count > 0:
				# Create a temp perk to get the base multiplier
				var temp_perk = Perk.create_perk(perk_type, rarity)
				
				# Apply the multiplier for each stack
				for i in range(stack_count):
					if perk_type == Perk.PerkType.ABILITY_COOLDOWN:
						# For cooldown reduction, multiply the reduction
						total_multiplier *= temp_perk.multiplier
					else:
						# For other stats, multiply the bonus
						total_multiplier *= temp_perk.multiplier
		
		cached_multipliers[perk_type] = total_multiplier
	
	cache_dirty = false

# Get rarity weight for random selection
func get_rarity_weight(rarity: Perk.Rarity, player_level: int) -> float:
	# Higher level players have better chances for rare perks
	match rarity:
		Perk.Rarity.COMMON:
			return 60.0 - (player_level * 2.0)  # Decreases as level increases
		Perk.Rarity.RARE:
			return 30.0 + (player_level * 1.0)  # Increases slightly with level
		Perk.Rarity.LEGENDARY:
			if player_level < 6:
				return 0.0  # Not available before level 6
			return 8.0 + (player_level * 0.5)
		Perk.Rarity.EPIC:
			if player_level < 6:
				return 0.0  # Not available before level 6
			return 2.0 + (player_level * 0.3)
		_:
			return 1.0

# Generate random perks for level up selection
func generate_random_perks(player_level: int, count: int = 3) -> Array[Perk]:
	var available_perks: Array[Perk] = []
	var perk_types = Perk.get_all_perk_types()
	
	# Generate many potential perks and filter available ones
	var potential_perks: Array[Perk] = []
	
	for perk_type in perk_types:
		for rarity in [Perk.Rarity.COMMON, Perk.Rarity.RARE, Perk.Rarity.LEGENDARY, Perk.Rarity.EPIC]:
			# Skip if rarity not available at this level
			if get_rarity_weight(rarity, player_level) <= 0:
				continue
			
			var perk = Perk.create_perk(perk_type, rarity)
			if can_add_perk(perk):
				potential_perks.append(perk)
	
	# If no perks available, return empty array
	if potential_perks.is_empty():
		return []
	
	# Randomly select perks based on rarity weights
	var selected_perks: Array[Perk] = []
	
	for i in range(count):
		if potential_perks.is_empty():
			break
		
		# Calculate total weight
		var total_weight = 0.0
		for perk in potential_perks:
			total_weight += get_rarity_weight(perk.rarity, player_level)
		
		# Random selection
		var random_value = randf() * total_weight
		var current_weight = 0.0
		
		for j in range(potential_perks.size()):
			var perk = potential_perks[j]
			current_weight += get_rarity_weight(perk.rarity, player_level)
			
			if random_value <= current_weight:
				selected_perks.append(perk)
				potential_perks.remove_at(j)
				break
	
	return selected_perks

# Get all current perks as a readable list
func get_all_perks_summary() -> Array[String]:
	var summary: Array[String] = []
	
	for perk_type in Perk.get_all_perk_types():
		for rarity in [Perk.Rarity.COMMON, Perk.Rarity.RARE, Perk.Rarity.LEGENDARY, Perk.Rarity.EPIC]:
			var stack_count = perk_stacks[perk_type][rarity]
			if stack_count > 0:
				var temp_perk = Perk.create_perk(perk_type, rarity)
				summary.append("%s (%s) x%d" % [temp_perk.perk_name, temp_perk.get_rarity_name(), stack_count])
	
	return summary

# Reset all perks (for testing or new game)
func reset_perks():
	for perk_type in perk_stacks:
		for rarity in perk_stacks[perk_type]:
			perk_stacks[perk_type][rarity] = 0
	cache_dirty = true
	perks_updated.emit()
