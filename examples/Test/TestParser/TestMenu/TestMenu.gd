extends GutTest

const Parser = preload("res://addons/Rakugo/lib/systems/Parser.gd")

@onready var parser := Parser.new()

var test_params = [
	[
		"menu menu:",
		"\"loop\" > menu",
		"\"end\""
	],
	[
		"menu menu:",
		"	\"loop\" > menu",
		"	\"end\""
	],
	[
		" menu menu:	",
		"	\"loop\" > menu ",
		"  \"end\""
	],
	[
		"menu menu:",
		"\"loop\" > menu",
		"\"end\"",
		""
	],
	[
		"menu menu:",
		"\"loop\" > menu",
		"\"end\"",
		"	"
	],
	[
		"menu menu:",
		"\"loop\" > menu",
		"\"end\"",
		"\"hello, world !\""
	],
	[
		"menu menu:",
		"\"loop\" > menu",
		"\"end\"",
		"# comment"
	]
]

func test_menu(params=use_parameters(test_params)):
	var parsed_script = parser.parse_script(params)
	
	assert_false(parsed_script.is_empty())

	var parsed_array = parsed_script["parse_array"]

	assert_false(parsed_array.is_empty())

	assert_eq(parsed_script["labels"], {"menu":0})

	var menu_choice_results = parsed_array[0][2]

	assert_eq(menu_choice_results[0].get_string("text"), "\"loop\"")

	assert_eq(menu_choice_results[0].get_string("label"), "menu")

	assert_eq(menu_choice_results[1].get_string("text"), "\"end\"")
