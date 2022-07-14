const DAY_NAMES := PoolStringArray(
	["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
)

const MONTH_NAMES := PoolStringArray(
	[
		"january",
		"february",
		"march",
		"april",
		"may",
		"june",
		"july",
		"august",
		"september",
		"october",
		"november",
		"december"
	]
)

var _data := {
	"a": "(?P<a>)",
	"A": "(?P<A>%s)" % DAY_NAMES.join("|"),
	"w": "(?P<w>[0-6])",
	"d": "(?P<d>3[0-1]|[1-2]\\d|0[1-9]|[1-9]| [1-9])",
	"D":
	"(?P<D>3[0-1](?:th|rd|st)|[1-2]\\d(?:th|rd|st)|0[1-9](?:th|rd|st)|[1-9](?:th|rd|st)| [1-9](?:th|rd|st))",
	"b": "(?P<b>)",
	"B": "(?P<B>%s)" % MONTH_NAMES.join("|"),
	"m": "(?P<m>1[0-2]|0[1-9]|[1-9])",
	"y": "(?P<y>\\d\\d)",
	"Y": "(?P<Y>\\d\\d\\d\\d)",
	"H": "(?P<H>2[0-3]|[0-1]\\d|\\d)",
	"I": "(?P<I>1[0-2]|0[1-9]|[1-9])",
	"p": "(?P<p>am|pm",
	"M": "(?P<M>[0-5]\\d|\\d)",
	"S": "(?P<S>6[0-1]|[0-5]\\d|\\d)",
	"j": "(?P<j>36[0-6]|3[0-5]\\d|[1-2]\\d\\d|0[1-9]\\d|00[1-9]|[1-9]\\d|0[1-9]|[1-9])",
	"U": "(?P<U>5[0-3]|[0-4]\\d|\\d)",
	"W": "(?P<W>5[0-3]|[0-4]\\d|\\d)",
	"%": "%"
}


func _init(data := _data) -> void:
	_data = data
	_data["a"] = "(?P<a>%s)" % day_names_short().join("|")
	_data["b"] = "(?P<b>%s)" % month_names_short().join("|")


func pattern(format):
	var processed_format = ""
	var regex_chars := RegEx.new()
	regex_chars.compile("([\\\\[.^$*+?\\(\\){}\\[\\]\\|])")
	format = regex_chars.sub(format, "\\$1", true)
	var whitespace_replacement := RegEx.new()
	whitespace_replacement.compile("\\s+")
	format = whitespace_replacement.sub(format, "\\s+", true)

	while "%" in format:
		var directive_index = format.find("%") + 1
		processed_format = (
			"%s%s%s"
			% [processed_format, format.left(directive_index - 1), _data[format[directive_index]]]
		)
		format = format.right(directive_index + 1)

	return "%s%s" % [processed_format, format]


static func month_names_short() -> PoolStringArray:
	var month_name_short := PoolStringArray([])
	for month_name in MONTH_NAMES:
		month_name_short.append(month_name.left(3))
	return month_name_short


static func day_names_short() -> PoolStringArray:
	var day_name_short := PoolStringArray([])
	for day_name in DAY_NAMES:
		day_name_short.append(day_name.left(3))
	return day_name_short


func compile(format):
	var re = RegEx.new()
	re.compile(self.pattern(format))
	return re
