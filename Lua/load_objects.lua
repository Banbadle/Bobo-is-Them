-- Here we add two new objects to the object list

table.insert(editor_objlist_order, "bobo")
table.insert(editor_objlist_order, "text_bobo")

table.insert(editor_objlist_order, "text_them")
table.insert(editor_objlist_order, "text_us")
table.insert(editor_objlist_order, "text_haunt")
table.insert(editor_objlist_order, "text_always")

-- This defines the exact data for them (note that since the sprites are specific to this levelpack, sprite_in_root must be false!)

editor_objlist["bobo"] = 
{
	name = "bobo",
	sprite_in_root = false,
	unittype = "object",
	tags = {"coop"},
	tiling = 2,
	type = 4,
	layer = 20,
	colour = {3, 3},
}

editor_objlist["text_bobo"] = 
{
	name = "text_bobo",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","coop"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {3, 2},
	colour_active = {3, 3},
}

editor_objlist["text_them"] = 
{
	name = "text_them",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","coop"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {3, 2},
	colour_active = {3, 3},
}

editor_objlist["text_us"] = 
{
	name = "text_us",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","coop"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {3, 0},
	colour_active = {3, 1},
}

editor_objlist["text_haunt"] = 
{
	name = "text_haunt",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract","coop"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
}

editor_objlist["text_always"] = 
{
	name = "text_always",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","coop"},
	tiling = -1,	
	type = 3,
	layer = 20,
	colour = {6, 1},
	colour_active = {2, 4},
}

-- After adding new objects to the list, formatobjlist() must be run to setup everything correctly.

formatobjlist()
