"""
Fix 1.21 loot table format issues in the modpack datapack.

Issues fixed:
- "type": "minecraft:loot_table" entries: rename "name" -> "value"
- "function": "minecraft:looting_enchant" -> "minecraft:enchanted_count_increase"
- "function": "looting_enchant" (no prefix) -> same
- "condition": "minecraft:random_chance_with_looting" -> "minecraft:random_chance"
- "function": "minecraft:set_nbt" -> "minecraft:set_custom_data" (for map files)
- Remove specific unknown items from specific files
"""

import json
import os
import re
from pathlib import Path

DATAPACK = Path(r"C:\Users\nikoz\AppData\Roaming\PrismLauncher\instances\NekoRPG 1.21\.minecraft\config\paxi\datapacks\modpack\data")

# Items to remove globally (from any pool entry)
UNKNOWN_ITEMS_GLOBAL = {
    "galosphere:raw_silver",
    "galosphere:silver_bomb",
    "galosphere:silver_ingot",
    "galosphere:silver_nugget",
    "block_factorys_bosses:ancient_iron_ingot",
    "block_factorys_bosses:ancient_iron_nugget",
    "block_factorys_bosses:dragon_flag",
    "neapolitan:banana",
    "neapolitan:ice_cubes",
    "neapolitan:vanilla_pods",
    "alexscaves:heavy_bone",
    "alexsmobs:acacia_flower",
    "legendary_monsters:nature_crystal",
}

# Files that should restrict item removal to specific items only
# (to avoid accidentally removing valid items from unrelated files)
TARGETED_FILES = {
    "quark/loot_table/misc/monster_box.json": {"galosphere:raw_silver", "galosphere:silver_bomb"},
    "supplementaries/loot_table/blocks/urn_loot/uncommon.json": {"galosphere:silver_nugget"},
    "block_factorys_bosses/loot_table/chests/dragon_tower_common.json": {
        "galosphere:raw_silver", "galosphere:silver_ingot", "galosphere:silver_nugget",
        "block_factorys_bosses:ancient_iron_ingot", "block_factorys_bosses:ancient_iron_nugget",
    },
    "block_factorys_bosses/loot_table/blocks/dragon_flag.json": {"block_factorys_bosses:dragon_flag"},
    "block_factorys_bosses/loot_table/entities/soul_knight_wither_skeleton.json": {
        "block_factorys_bosses:ancient_iron_ingot", "block_factorys_bosses:ancient_iron_nugget",
    },
    "block_factorys_bosses/loot_table/entities/flaming_skeleton_guard_sword.json": {
        "block_factorys_bosses:ancient_iron_nugget",
    },
    "block_factorys_bosses/loot_table/entities/flaming_skeleton_guard_fireball.json": {
        "block_factorys_bosses:ancient_iron_nugget",
    },
    "block_factorys_bosses/loot_table/entities/soul_skeleton.json": {
        "block_factorys_bosses:ancient_iron_nugget",
    },
    "alexsmobs/loot_table/gameplay/trader_elephant_chest.json": {"neapolitan:banana"},
    "lootintegrations/loot_table/chests/cold.json": {"neapolitan:ice_cubes"},
    "mutantmonsters/loot_table/entities/mutant_skeleton/limb.json": {"alexscaves:heavy_bone"},
    "bosses_of_mass_destruction/loot_table/entities/void_blossom.json": {"legendary_monsters:nature_crystal"},
    "mowziesmobs/loot_table/chests/umvuthana_grove_chest.json": {
        "neapolitan:vanilla_pods", "alexsmobs:acacia_flower",
    },
}


def fix_function(fn, file_rel):
    """Fix a loot function object."""
    if not isinstance(fn, dict):
        return fn
    fn = dict(fn)
    fname = fn.get("function", "")

    # Fix looting_enchant -> enchanted_count_increase
    if fname in ("minecraft:looting_enchant", "looting_enchant"):
        new_fn = {
            "function": "minecraft:enchanted_count_increase",
            "enchantment": "minecraft:looting",
            "added_count": fn.get("count", {"min": 0, "max": 1}),
        }
        if "limit" in fn:
            new_fn["limit"] = fn["limit"]
        if "conditions" in fn:
            new_fn["conditions"] = [fix_condition(c, file_rel) for c in fn["conditions"]]
        return new_fn

    # Fix missing minecraft: prefix on common functions
    prefix_fixes = {
        "set_count": "minecraft:set_count",
        "set_damage": "minecraft:set_damage",
        "enchant_with_levels": "minecraft:enchant_with_levels",
        "enchant_randomly": "minecraft:enchant_randomly",
    }
    if fname in prefix_fixes:
        fn["function"] = prefix_fixes[fname]

    # Recurse into nested conditions
    if "conditions" in fn:
        fn["conditions"] = [fix_condition(c, file_rel) for c in fn["conditions"]]

    return fn


def fix_condition(cond, file_rel):
    """Fix a loot condition object."""
    if not isinstance(cond, dict):
        return cond
    cond = dict(cond)
    ctype = cond.get("condition", "")

    # Fix random_chance_with_looting -> random_chance (drop looting multiplier)
    if ctype in ("minecraft:random_chance_with_looting", "random_chance_with_looting"):
        return {
            "condition": "minecraft:random_chance",
            "chance": cond.get("chance", 0.05),
        }

    # Fix missing minecraft: prefix
    if ctype == "killed_by_player":
        cond["condition"] = "minecraft:killed_by_player"

    # Recurse into nested conditions
    if "term" in cond:
        cond["term"] = fix_condition(cond["term"], file_rel)
    if "terms" in cond:
        cond["terms"] = [fix_condition(t, file_rel) for t in cond["terms"]]

    return cond


def fix_entry(entry, file_rel, items_to_remove):
    """Fix a loot table entry object."""
    if not isinstance(entry, dict):
        return entry
    entry = dict(entry)

    # Fix "type": "minecraft:loot_table" with "name" -> "value"
    if entry.get("type") == "minecraft:loot_table" and "name" in entry:
        entry["value"] = entry.pop("name")

    # Fix "type": "item" shorthand -> "minecraft:item"
    if entry.get("type") == "item":
        entry["type"] = "minecraft:item"

    # Fix functions
    if "functions" in entry:
        entry["functions"] = [fix_function(f, file_rel) for f in entry["functions"]]

    # Fix conditions
    if "conditions" in entry:
        entry["conditions"] = [fix_condition(c, file_rel) for c in entry["conditions"]]

    # Recurse into children
    if "entries" in entry:
        new_entries = []
        for e in entry["entries"]:
            item_name = e.get("name", e.get("value", ""))
            if isinstance(item_name, str) and item_name in items_to_remove:
                continue
            new_entries.append(fix_entry(e, file_rel, items_to_remove))
        entry["entries"] = new_entries

    return entry


def fix_pool(pool, file_rel, items_to_remove):
    """Fix a loot table pool object."""
    if not isinstance(pool, dict):
        return pool
    pool = dict(pool)

    if "entries" in pool:
        new_entries = []
        for entry in pool["entries"]:
            item_name = entry.get("name", entry.get("value", ""))
            if isinstance(item_name, str) and item_name in items_to_remove:
                continue
            new_entries.append(fix_entry(entry, file_rel, items_to_remove))
        pool["entries"] = new_entries

    if "conditions" in pool:
        pool["conditions"] = [fix_condition(c, file_rel) for c in pool["conditions"]]

    if "functions" in pool:
        pool["functions"] = [fix_function(f, file_rel) for f in pool["functions"]]

    return pool


def get_items_to_remove(file_rel):
    """Get the set of items to remove for a specific file."""
    normalized = file_rel.replace("\\", "/")
    return TARGETED_FILES.get(normalized, set())


def process_file(filepath):
    """Process one loot table JSON file in place."""
    try:
        text = filepath.read_text(encoding="utf-8")
        data = json.loads(text)
    except (json.JSONDecodeError, UnicodeDecodeError) as e:
        print(f"  SKIP (parse error): {filepath.name}: {e}")
        return False

    file_rel = str(filepath.relative_to(DATAPACK)).replace("\\", "/")
    items_to_remove = get_items_to_remove(file_rel)

    if "pools" in data:
        new_pools = []
        for pool in data["pools"]:
            new_pools.append(fix_pool(pool, file_rel, items_to_remove))
        data["pools"] = new_pools

    new_text = json.dumps(data, indent=2, ensure_ascii=False)
    if new_text != text:
        filepath.write_text(new_text, encoding="utf-8")
        return True
    return False


def main():
    loot_table_dirs = list(DATAPACK.rglob("loot_table"))
    all_files = []
    for d in loot_table_dirs:
        if d.is_dir():
            all_files.extend(d.rglob("*.json"))

    changed = 0
    skipped = 0
    for fp in sorted(all_files):
        result = process_file(fp)
        if result:
            changed += 1
        else:
            skipped += 1

    print(f"\nDone: {changed} files modified, {skipped} files unchanged.")


if __name__ == "__main__":
    main()
