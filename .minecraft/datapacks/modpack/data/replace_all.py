import os

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

root = input("\nSearch dir: " + bcolors.OKBLUE)
print(bcolors.ENDC)
root.replace("\\", "/")
if not root.startswith("./"):
    if root.startswith("."):
        root = root[0] + "/" + root[1:]
    else:
        root = "." + root

mod_id = input("Removed mod id: " + bcolors.OKBLUE)
print(bcolors.ENDC)
if len(mod_id) == 0:
    raise Exception("Invalid mod id: length must be greater than zero")

filter = input("Filter entries: " + bcolors.OKBLUE)
print(bcolors.ENDC)
if filter.find(":") != -1 or filter.find(".") != -1 or filter.find("\"") != -1 or filter.find("'") != -1 or filter.find("`") != -1:
    raise Exception("Invalid filter: cannot contain characters \":.'`")

strict = False
if len(filter) > 0:
    strict = input("Strict filtering?\n(true/false): " + bcolors.OKBLUE).lower()
    print(bcolors.ENDC)
    if strict != "true" and strict != "false":
        raise Exception("Invalid argument: must be either \"true\" or \"false\"")

ask_confirm = input("Ask for confirmations?\n(true/false): " + bcolors.OKBLUE).lower()
print(bcolors.ENDC)
if ask_confirm != "true" and ask_confirm != "false":
    raise Exception("Invalid argument: must be either \"true\" or \"false\"")

json = []
nbt = []
replace_entries: dict[str, str] = {}
replaced_count = 0
file_count = 0

def hasFilter(sub: str):
    if len(filter) == 0:
        return True
    if strict == "true":
        return sub.lower() == filter.lower()
    return sub.find(filter) != -1

if os.path.exists("./entries_save.txt"):
    load_existing = input("Load existing data from entries_save.txt?\n(true/false): " + bcolors.OKBLUE).lower()
    print(bcolors.ENDC)
    if load_existing != "true" and load_existing != "false":
        raise Exception("Invalid argument: must be either \"true\" or \"false\"")
    if load_existing == "true":
        entries_file = open("./entries_save.txt", "r+")
        line = entries_file.readline()
        while len(line) > 0:
            split = line.split()
            if split[0].split(":")[0] == mod_id and hasFilter(split[0].split(":")[1]):
                print(bcolors.OKCYAN + "LOADED ENTRY [" + split[0] + " -> " + split[1] + "]" + bcolors.ENDC)
                replace_entries[split[0]] = split[1]
            line = entries_file.readline()
        entries_file.close()

for path, dirs, files in os.walk(root):
    for file in files:
        file: str = os.path.join(path, file)
        if file.endswith(".json"):
            # print("Found json file \"" + file + "\"")
            json.append(file)
        elif file.endswith(".nbt"):
            # print("Found nbt file \"" + file + "\"")
            nbt.append(file)
        else:
            # print("Skipping non-json file \"" + file + "\"")
            pass

entries_file = open("./entries_save.txt", "a+")
for file in json:
    stream = open(file, "r")
    as_str = ""
    try:
        as_str = stream.read()
    except UnicodeDecodeError as e:
        print(bcolors.FAIL + "\nException trying to read file " + file + bcolors.ENDC)
        continue
    stream.close()
    
    # Find any undefined entries
    undefined: dict[str, str] = {}
    start = 0
    while True:
        start = as_str.find(mod_id, start)
        if start == -1:
            break
        found_id = as_str[start:as_str.find(":", start)]
        end = as_str.find("\"", start)
        if found_id == mod_id:
            item = as_str[start:end]
            if (not item in replace_entries) and hasFilter(item):
                undefined[item] = ""
        start = end
    
    # Define replacements for any undefined entries
    for i, v in undefined.items():
        replace = input(bcolors.OKGREEN + "\n> " + bcolors.ENDC + "Found new entry " + bcolors.OKBLUE + i + bcolors.ENDC + " in file " + bcolors.OKCYAN + file + bcolors.ENDC + "\nReplace with: " + bcolors.OKBLUE)
        print(bcolors.ENDC)
        item_count = 0
        for s in replace.split(":"):
            item_count += 1
            if len(s) == 0 or s.find("\"") != -1 or s.endswith("\\") or s.find(":") != -1:
                item_count = 0
                break
        if item_count != 2:
            print(bcolors.WARNING + "> Invalid replacement, skipping..." + bcolors.ENDC)
        else:
            replace_entries[i] = replace
            entries_file.write(i + " " + replace + "\n")
        
    # Replace all defined entries
    file_affected = False
    for i, v in replace_entries.items():
        if as_str.find(i) == -1:
            continue
        if ask_confirm == "true":
            skip = input("\nReplace all occurrences of " + bcolors.OKBLUE + i + bcolors.ENDC + " in file " + bcolors.OKCYAN + file + bcolors.ENDC + " with " + bcolors.OKBLUE + v + bcolors.ENDC + "?\n(Enter to confirm, type anything to skip): ")
            if len(skip) > 0:
                print(bcolors.OKGREEN + "> " + bcolors.ENDC + "Skipping...")
                continue
        else:
            print(bcolors.OKGREEN + "> " + bcolors.ENDC + "ask_confirm = " + ask_confirm)
        replaced_count += as_str.count(i)
        as_str = as_str.replace(i, v)
        print(bcolors.OKGREEN + "\n> " + bcolors.ENDC + "Replaced all occurrences of " + bcolors.OKBLUE + i + bcolors.ENDC + " in file " + bcolors.OKCYAN + file + bcolors.ENDC + " with " + bcolors.OKBLUE + v + bcolors.ENDC)
        file_affected = True
    if file_affected:
        file_count += 1
    
    # Write to file
    stream = open(file, "w")
    stream.write(as_str)
    stream.close()

# for file in nbt:
#     stream = open(file, "r")
#     as_str = stream.read()
#     stream.close()
#     print(bcolors.HEADER + "== NBT file contents ==\n\n" + bcolors.ENDC + as_str + bcolors.HEADER + "=======================" + bcolors.ENDC)

entries_file.close()
print(bcolors.OKGREEN + "\nFound and replaced " + str(replaced_count) + " values across " + str(file_count) + " files from mod with id " + mod_id + "\n" + bcolors.ENDC)
