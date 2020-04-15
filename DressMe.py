import mysql.connector
from slpp import slpp as lua
from collections import namedtuple, OrderedDict, Iterable
from pprint import pprint


db = mysql.connector.connect(
  host="localhost",
  user="root",
  passwd="root",
  database="world"
)

cursor = db.cursor()

quality_colors = [
    "ff9d9d9d",
    "ffffffff",
    "ff1eff00",
    "ff0070dd",
    "ffa335ee",
    "ffff8000",
    "ffe6cc80",
    "ff00ccff",
]

def get_colored_name(name, quality):
    return "|c{0}{1}|r".format(quality_colors[quality], name)

query = """SELECT displayid, entry, name, quality FROM item_template
    WHERE
        quality >= %s AND quality <= %s
        AND inventorytype in {0}
        AND class = %s AND subclass = %s
    ORDER BY
        quality, itemlevel, requiredlevel; """

result = {}

# {
#     Armor: {...},
#     Main Hand: {...},
#     Off hand: {...},
#     Ranged: {...},
# }


# ---------------- ARMOR ----------------
# {
#   Slot1: {
#       Subclass1: [
#           [entry1, entry2, ..., entryN], [name1, name2, ..., nameN]],
#           [entry1, entry2, ..., entryN], [name1, name2, ..., nameN]],
#           ...
#       ]
# },
# {
#   Slot2: {
#       ...
# },
# ...

armor_subclasses = {"Miscellaneous": 0, "Cloth": 1, "Leather": 2, "Mail": 3, "Plate": 4}

armor_slots = OrderedDict([
    ("Head",     {"inventorytype": (1,),    "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
    ("Shoulder", {"inventorytype": (3,),    "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
    ("Back",     {"inventorytype": (16,),   "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
    ("Chest",    {"inventorytype": (5, 20), "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
    ("Shirt",    {"inventorytype": (4,),    "class": 4, "subclasses": armor_subclasses, "minquality": 0, "maxquality": 7}),
    ("Tabard",   {"inventorytype": (19,),   "class": 4, "subclasses": armor_subclasses, "minquality": 0, "maxquality": 7}),
    ("Wrist",    {"inventorytype": (9,),    "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
    ("Hands",    {"inventorytype": (10,),   "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
    ("Waist",    {"inventorytype": (6,),    "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
    ("Legs",     {"inventorytype": (7,),    "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
    ("Feet",     {"inventorytype": (8,),    "class": 4, "subclasses": armor_subclasses, "minquality": 2, "maxquality": 7}),
])

armor_result = OrderedDict()

for slot, columns in armor_slots.items():
    armor_result[slot] = {}
    for subclass in columns["subclasses"]:
        grouped_by_display_id = OrderedDict()
        # I know, this looks awful.
        cursor.execute(
            query.format(
                columns["inventorytype"] if len(columns["inventorytype"]) > 1 else "({0})".format(columns["inventorytype"][0])
            ), 
            (
                columns["minquality"],
                columns["maxquality"],
                columns["class"],
                columns["subclasses"][subclass]
            )
        )
        for display_id, entry, name, quality in cursor:
            if display_id not in grouped_by_display_id:
                grouped_by_display_id[display_id] = [[entry], [get_colored_name(name, quality if quality > 0 else 1)]]
            else:
                grouped_by_display_id[display_id][0].append(entry)
                grouped_by_display_id[display_id][1].append(get_colored_name(name, quality if quality > 0 else 1))
        if grouped_by_display_id:
            armor_result[slot][subclass] = []
            for display_id in grouped_by_display_id:
                armor_result[slot][subclass].append(grouped_by_display_id[display_id])
        
result.update({"Armor": armor_result})


# ---------------- WEAPON AND SHIELD ----------------
#
# {
#   Main Hand: {
#       Subclass1: [
#           [entry1, entry2, ..., entryN], [name1, name2, ..., nameN]],
#       ],
#       Subclass2: [
#           [entry1, entry2, ..., entryN], [name1, name2, ..., nameN]],
#       ],
#       ...
#       SubclassN: [
#           [entry1, entry2, ..., entryN], [name1, name2, ..., nameN]],
#       ],
#   },
#   Off hand: {
#       ...
#   },
#   Ranged: {
#        ...
#   },
# }

min_quality = 2
max_quality = 7

main_hand_weapon = OrderedDict([
    ("2H Axe",       {"inventorytype": (17, ), "class": 2, "subclass": 1}),
    ("2H Mace",      {"inventorytype": (17, ), "class": 2, "subclass": 5}),
    ("2H Sword",     {"inventorytype": (17, ), "class": 2, "subclass": 8}),
    ("Polearm",      {"inventorytype": (17, ), "class": 2, "subclass": 6}),
    ("Staff",        {"inventorytype": (17, ), "class": 2, "subclass": 10}),

    ("1H Axe",       {"inventorytype": (13, ), "class": 2, "subclass": 0}),
    ("1H Mace",      {"inventorytype": (13, ), "class": 2, "subclass": 4}),
    ("1H Sword",     {"inventorytype": (13, ), "class": 2, "subclass": 7}),
    ("1H Dagger",    {"inventorytype": (13, ), "class": 2, "subclass": 15}),
    ("1H Fist",      {"inventorytype": (13, ), "class": 2, "subclass": 13}),

    ("MH Axe",       {"inventorytype": (21, ), "class": 2, "subclass": 0}),
    ("MH Mace",      {"inventorytype": (21, ), "class": 2, "subclass": 4}),
    ("MH Sword",     {"inventorytype": (21, ), "class": 2, "subclass": 7}),
    ("MH Dagger",    {"inventorytype": (21, ), "class": 2, "subclass": 15}),
    ("MH Fist",      {"inventorytype": (21, ), "class": 2, "subclass": 13}),
])

off_hand_weapon = OrderedDict([
    ("1H Axe",       {"inventorytype": (13, ), "class": 2, "subclass": 0}),
    ("1H Mace",      {"inventorytype": (13, ), "class": 2, "subclass": 4}),
    ("1H Sword",     {"inventorytype": (13, ), "class": 2, "subclass": 7}),
    ("1H Dagger",    {"inventorytype": (13, ), "class": 2, "subclass": 15}),
    ("1H Fist",      {"inventorytype": (13, ), "class": 2, "subclass": 13}),

    ("OH Axe",       {"inventorytype": (22, ), "class": 2, "subclass": 0}),
    ("OH Mace",      {"inventorytype": (22, ), "class": 2, "subclass": 4}),
    ("OH Sword",     {"inventorytype": (22, ), "class": 2, "subclass": 7}),
    ("OH Dagger",    {"inventorytype": (22, ), "class": 2, "subclass": 15}),
    ("OH Fist",      {"inventorytype": (22, ), "class": 2, "subclass": 13}),

    ("Shield",              {"inventorytype": (14, ), "class": 4, "subclass": 6}),
    ("Held in Off-hand",    {"inventorytype": (23, ), "class": 4, "subclass": 0}),
])

ranged_weapon = OrderedDict([
    ("Bow",         {"inventorytype": (15, ), "class": 2, "subclass": 2}),
    ("Crossbow",    {"inventorytype": (26, ), "class": 2, "subclass": 18}),
    ("Gun",         {"inventorytype": (26, ), "class": 2, "subclass": 3}),
    ("Thrown",      {"inventorytype": (25, ), "class": 2, "subclass": 16}),
    ("Wand",        {"inventorytype": (26, ), "class": 2, "subclass": 19}),
])


def get_data(items):
    result = OrderedDict()
    for weapon, columns in items:
        cursor.execute(
            query.format(
                columns["inventorytype"] if len(columns["inventorytype"]) > 1 else "({0})".format(columns["inventorytype"][0])
            ), 
            (
                min_quality, max_quality,
                columns["class"],
                columns["subclass"]
            )
        )
        grouped_by_display_id = OrderedDict()
        for display_id, entry, name, quality in cursor:
            if display_id not in grouped_by_display_id:
                grouped_by_display_id[display_id] = [[entry], [get_colored_name(name, quality)]]
            else:
                grouped_by_display_id[display_id][0].append(entry)
                grouped_by_display_id[display_id][1].append(get_colored_name(name, quality))
        if grouped_by_display_id:
            result[weapon] = []
            for display_id in grouped_by_display_id:
                result[weapon].append(grouped_by_display_id[display_id])
    return result


result.update({"Main Hand": get_data(main_hand_weapon.items())})
result.update({"Off-hand": get_data(off_hand_weapon.items())})
result.update({"Ranged": get_data(ranged_weapon.items())})


def to_lua(data, indent = "    ", level = 0):
    if isinstance(data, (int, float)):
        return str(data)
    elif isinstance(data, str):
        return "\"" + data.replace("\"", "\\\"").replace("\'", "\\\'") + "\""
    elif isinstance(data, (list, tuple)):
        s = "{\n"
        for v in data:
            s += indent * (level + 1) + to_lua(v, indent, level + 1) + ",\n"
        s += indent * level + "}"
        return s
    elif isinstance(data, (dict, OrderedDict)):
        s = "{\n"
        for k, v in data.items():
            s += "{0}[\"{1}\"] = {2},\n".format(indent * (level + 1), k, to_lua(v, indent, level + 1))
        s += indent * level + "}"
        return s
    else:
        raise KeyError("Cannot conver a non-buil-in python type to a lua table!")

with open("db\\Items.lua", "w+") as file:
    file.write("local addon, ns = ...\n\nlocal data = " + to_lua(result) + "\n\nfunction ns:GetItemsData()\n    return data\nend\n")
db.close()